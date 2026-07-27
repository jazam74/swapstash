import 'package:flutter/material.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  final Future<void> Function() onComplete;
  final bool isReplay;

  const OnboardingPage({
    super.key,
    required this.onComplete,
    this.isReplay = false,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _completing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_completing) {
      return;
    }

    setState(() {
      _completing = true;
    });

    try {
      await widget.onComplete();
    } finally {
      if (mounted) {
        setState(() {
          _completing = false;
        });
      }
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pages = [
      _OnboardingData(
        icon: Icons.collections_bookmark_outlined,
        title: localizations.betaOnboardingCollectionsTitle,
        description: localizations.betaOnboardingCollectionsDescription,
      ),
      _OnboardingData(
        icon: Icons.swap_horiz_rounded,
        title: localizations.betaOnboardingTradesTitle,
        description: localizations.betaOnboardingTradesDescription,
      ),
      _OnboardingData(
        icon: Icons.local_shipping_outlined,
        title: localizations.betaOnboardingCompleteTradeTitle,
        description: localizations.betaOnboardingCompleteTradeDescription,
      ),
      _OnboardingData(
        icon: Icons.shield_outlined,
        title: localizations.betaOnboardingSafetyTitle,
        description: localizations.betaOnboardingSafetyDescription,
      ),
    ];

    final isLastPage = _currentPage == pages.length - 1;

    return Scaffold(
      appBar: widget.isReplay
          ? AppBar(
              title: Text(localizations.betaOnboardingTitle),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.isReplay)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 30,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        localizations.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: _completing ? null : _complete,
                      child: Text(localizations.betaOnboardingSkip),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingContent(data: pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: index == _currentPage ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                      onPressed: _completing
                          ? null
                          : isLastPage
                          ? _complete
                          : _nextPage,
                      icon: _completing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              isLastPage
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                            ),
                      label: Text(
                        isLastPage
                            ? (widget.isReplay
                                  ? localizations.done
                                  : localizations.betaOnboardingStart)
                            : localizations.continueLabel,
                      ),
                    ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingContent({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 66,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 34),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
