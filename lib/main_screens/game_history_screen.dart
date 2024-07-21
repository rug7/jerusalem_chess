
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../providers/theme_language_provider.dart';
import '../providers/authentication_provider.dart';
import '../helper/helper_methods.dart';

class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  late ThemeLanguageProvider _themeLanguageProvider;
  Map<String, dynamic> translations = {};
  List<Map<String, dynamic>> gameHistory = [];
  bool isLoading = true;
  int initialWins = 0;
  int initialLosses = 0;
  Map<String, String?> opponentImages = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeLanguageProvider = Provider.of<ThemeLanguageProvider>(context);
    loadTranslations(_themeLanguageProvider.currentLanguage).then((value) {
      if (mounted) {
        setState(() {
          translations = value;
        });
      }
    });

    // Fetch initial wins and losses and then fetch game history
    fetchInitialWinsAndLosses().then((_) {
      fetchGameHistory();
    });
  }

  Future<void> fetchInitialWinsAndLosses() async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          initialWins = userDoc['wins'] ?? 0;
          initialLosses = userDoc['losses'] ?? 0;
        });
      }
    }
  }

  void reloadTranslations(String language) {
    loadTranslations(language).then((value) {
      if (mounted) {
        setState(() {
          translations = value;
        });
      }
    });
  }

  Future<void> fetchGameHistory() async {
    final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final userModel = authProvider.userModel;

    if (userModel != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .get();

      if (userDoc.exists && mounted) {
        final List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(userDoc['gameHistory'] ?? []);
        Map<String, Map<String, dynamic>> uniqueGames = {};

        // Fetch opponent images and filter duplicates
        for (var game in history) {
          final gameId = game['gameId'];
          if (gameId != null) {
            uniqueGames[gameId] = game;

            // Fetch opponent images
            if (game['opponentId'] != null) {
              final opponentId = game['opponentId'];
              final opponentDoc = await FirebaseFirestore.instance.collection('users').doc(opponentId).get();
              if (opponentDoc.exists) {
                opponentImages[opponentId] = opponentDoc['image'];
              }
            }
          }
        }

        setState(() {
          gameHistory = uniqueGames.values.toList();
          isLoading = false;
        });
      }
    }
  }

  void showMovesDialog(List<String> moves, String playerName, String opponentName) {
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslation('Moves', translations)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Table(
                  border: TableBorder.all(color: textColor, width: 2),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            playerName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            opponentName,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...List.generate((moves.length / 2).ceil(), (index) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              moves.length > index * 2 ? moves[index * 2] : '',
                              style: TextStyle(fontSize: 16, color: textColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              moves.length > index * 2 + 1 ? moves[index * 2 + 1] : '',
                              style: TextStyle(fontSize: 16, color: textColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(getTranslation('Close', translations)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthenticationProvider>(context);
    final userModel = authProvider.userModel;
    final textColor = _themeLanguageProvider.isLightMode ? Colors.black : Colors.white;
    final backgroundColor = _themeLanguageProvider.isLightMode ? Colors.white : const Color(0xFF121212);

    double totalGames = (initialWins/2) + (initialLosses/2);
    double winLossRatio = totalGames == 0 ? 0.0 : (initialWins/2) / totalGames;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff4e3c96),
        title: Text(getTranslation('gameHistory', translations),
            style: const TextStyle(color: Colors.white, fontFamily: 'IBM Plex Sans Arabic', fontWeight: FontWeight.w700)),
        actions: [
          // Dark mode toggle button
          IconButton(
            icon: Icon(_themeLanguageProvider.isLightMode ? Icons.light_mode : Icons.dark_mode),
            color: _themeLanguageProvider.isLightMode ? const Color(0xfff0c230) : const Color(0xfff0f5f7),
            onPressed: _themeLanguageProvider.toggleThemeMode,
          ),
          // Language change button
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (String selectedLanguage) {
              _themeLanguageProvider.changeLanguage(selectedLanguage);
              reloadTranslations(selectedLanguage);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'Arabic',
                child: Text(getTranslation('Arabic', translations)),
              ),
              PopupMenuItem<String>(
                value: 'English',
                child: Text(getTranslation('English', translations)),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Profile section
              Row(
                children: [
                  if (userModel?.image != null && userModel!.image.isNotEmpty)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(userModel.image),
                    )
                  else
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getTranslation('Wins', translations)}: ${initialWins}',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${getTranslation('Losses', translations)}: ${initialLosses}',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${getTranslation('W/L Ratio', translations)}: ${winLossRatio.toStringAsFixed(2)}',
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Table(
                border: TableBorder.all(color: const Color(0xff4e3c96), width: 1),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    children: [
                      tableHeaderCell(getTranslation('Players', translations), textColor),
                      tableHeaderCell(getTranslation('Moves', translations), textColor),
                      tableHeaderCell(getTranslation('Date', translations), textColor),
                    ],
                  ),
                  ...gameHistory.map((game) {
                    final playerName = userModel?.name ?? 'Unknown';
                    final playerImage = userModel?.image;
                    final opponentName = game['opponentName'] ?? 'Unknown';
                    final opponentId = game['opponentId'] ?? '';
                    final opponentImage = opponentImages[opponentId] ?? '';
                    final moves = List<String>.from(game['moves'] ?? []);
                    final creationTime = game['creationTime'];
                    final formattedCreationTime = creationTime is Timestamp
                        ? DateFormat('MMM dd, yyyy').format(creationTime.toDate())
                        : creationTime.toString().split(' ')[0];

                    return TableRow(
                      children: [
                        playersCell(playerName, playerImage, opponentName, opponentImage, textColor),
                        GestureDetector(
                          onTap: () => showMovesDialog(moves, playerName, opponentName),
                          child: movesTableCell(getTranslation('Show Moves', translations), textColor),
                        ),
                        tableCell(formattedCreationTime, textColor),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tableHeaderCell(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget tableCell(String content, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: TextStyle(color: textColor, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget movesTableCell(String content, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: TextStyle(
          color: textColor,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget playersCell(String playerName, String? playerImage, String opponentName, String? opponentImage, Color textColor) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (playerImage != null && playerImage.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(playerImage),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  playerName,
                  style: TextStyle(color: textColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              if (opponentImage != null && opponentImage.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(opponentImage),
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 16, color: Colors.white),
                ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  opponentName,
                  style: TextStyle(color: textColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getTranslation(String key, Map<String, dynamic> translations) {
    return translations[key] ?? key;
  }
}
