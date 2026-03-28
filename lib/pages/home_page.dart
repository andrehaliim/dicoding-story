import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story/l10n/app_localizations.dart';
import 'package:story/providers/locale_provider.dart';
import 'package:story/models/story_model.dart';
import 'package:story/proxys/story_proxy.dart';

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
  List<StoryModel> stories = [];
  int page = 1;
  int size = 10;
  final ScrollController scrollController = ScrollController();
  bool isFirstLoad = false;
  bool isLoadMore = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    getNickname();
    getStories();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent) {
        if (!isLoadMore && hasMore) {
          getMoreStories();
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshCount != widget.refreshCount) {
      page = 1;
      hasMore = true;
      stories.clear();
      getStories();
    }
  }

  Future<void> getNickname() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      nickname = sharedPreferences.getString('name') ?? '';
    });
  }

  Future<void> getStories() async {
    setState(() {
      isFirstLoad = true;
    });
    try {
      final fetchedStories = await StoryProxy().getPaginationStories(
        page: page,
        size: size,
      );
      setState(() {
        if (fetchedStories.length < size) {
          hasMore = false;
        } else {
          hasMore = true;
        }
        stories.addAll(fetchedStories);
        page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isFirstLoad = false;
        });
      }
    }
  }

  Future<void> getMoreStories() async {
    if (!mounted) return;
    setState(() {
      isLoadMore = true;
    });
    try {
      final fetchedStories = await StoryProxy().getPaginationStories(
        page: page,
        size: size,
      );
      setState(() {
        if (fetchedStories.length < size) {
          hasMore = false;
        }
        stories.addAll(fetchedStories);
        page++;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading more: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadMore = false;
        });
      }
    }
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
      body: isFirstLoad
          ? const Center(child: CircularProgressIndicator())
          : stories.isEmpty
          ? Center(child: Text(l10n.noStories))
          : ListView.builder(
              controller: scrollController,
              itemCount: stories.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == stories.length && hasMore) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
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
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onUpload,
        child: const Icon(Icons.add),
      ),
    );
  }
}
