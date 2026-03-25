import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/l10n/app_localizations.dart';
import 'package:story/providers/locale_provider.dart';
import 'package:story/models/story-model.dart';
import 'package:story/proxys/story-proxy.dart';

class HomePage extends StatefulWidget {
  final Function(StoryModel) onTapped;
  final Function() onShowLogoutDialog;
  final Function() onUpload;
  final int refreshCount;
  const HomePage({
    super.key,
    required this.onTapped,
    required this.onShowLogoutDialog,
    required this.onUpload,
    this.refreshCount = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String nickname = '';
  late Future<List<StoryModel>> _stories;

  @override
  void initState() {
    super.initState();
    getNickname();
    getStories();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshCount != widget.refreshCount) {
      setState(() {
        getStories();
      });
    }
  }

  Future<void> getNickname() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      nickname = sharedPreferences.getString('name') ?? '';
    });
  }

  Future<void> getStories() async {
    _stories = StoryProxy().getAllStories();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.story),
        actions: [
          TextButton(
            onPressed: () => localeProvider.toggleLocale(),
            child: Text(
              localeProvider.isEnglish ? 'ID' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onShowLogoutDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<StoryModel>>(
        future: _stories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final stories = snapshot.data!;
            return ListView.builder(
              itemCount: stories.length,
              itemBuilder: (context, index) {
                final story = stories[index];
                return GestureDetector(
                  onTap: () {
                    widget.onTapped(story);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          story.photoUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                story.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(story.description),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: Text(l10n.noStories));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onUpload,
        child: const Icon(Icons.add),
      ),
    );
  }
}

