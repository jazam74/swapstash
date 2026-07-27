import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:swapstash/core/models/trade_item.dart';
import 'package:swapstash/core/models/user_profile.dart';
import 'package:swapstash/core/services/firestore_service.dart';
import 'package:swapstash/core/services/trade_service.dart';
import 'package:swapstash/features/trades/models/manual_trade_data.dart';
import 'package:swapstash/features/trades/services/manual_trade_service.dart';
import 'package:swapstash/l10n/generated/app_localizations.dart';

class CreateTradePage extends StatefulWidget {
  const CreateTradePage({super.key});

  @override
  State<CreateTradePage> createState() => _CreateTradePageState();
}

class _CreateTradePageState extends State<CreateTradePage> {
  final FirestoreService _firestoreService = FirestoreService();
  final ManualTradeService _manualTradeService = ManualTradeService();
  final TradeService _tradeService = TradeService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchDebounce;

  int _step = 0;
  int _searchRequestId = 0;

  List<UserProfile> _searchResults = [];
  UserProfile? _selectedUser;

  ManualTradeData? _tradeData;
  String? _selectedCollectionId;

  final Map<String, int> _offeredQuantities = {};
  final Map<String, int> _requestedQuantities = {};

  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingOptions = false;
  bool _isSending = false;
  bool _showAllSurpluses = false;

  String? _searchError;
  String? _optionsError;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();

    final query = value.trim();

    setState(() {
      _searchError = null;

      if (query.isEmpty) {
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
        _searchRequestId++;
      } else {
        _isSearching = true;
        _hasSearched = false;
      }
    });

    if (query.isEmpty) {
      return;
    }

    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchUsers(query),
    );
  }

  Future<void> _searchUsers(String query) async {
    final requestId = ++_searchRequestId;

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final users = await _firestoreService.searchUsers(query);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;

      final filteredUsers = users
          .where((user) => user.uid != currentUserId && user.isPublic)
          .toList(growable: false);

      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _searchResults = filteredUsers;
        _hasSearched = true;
      });
    } catch (error) {
      if (!mounted || requestId != _searchRequestId) {
        return;
      }

      setState(() {
        _searchResults = [];
        _searchError = AppLocalizations.of(
          context,
        )!.tradeUserSearchError(error.toString());
        _hasSearched = true;
      });
    } finally {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchRequestId++;

    setState(() {
      _searchResults = [];
      _searchError = null;
      _isSearching = false;
      _hasSearched = false;
    });
  }

  void _selectUser(UserProfile user) {
    _searchDebounce?.cancel();
    _searchController.clear();

    setState(() {
      _selectedUser = user;
      _searchResults = [];
      _searchError = null;
      _isSearching = false;
      _hasSearched = false;
      _tradeData = null;
      _selectedCollectionId = null;
      _showAllSurpluses = false;
      _offeredQuantities.clear();
      _requestedQuantities.clear();
      _optionsError = null;
    });

    FocusScope.of(context).unfocus();
  }

  void _changeRecipient() {
    setState(() {
      _step = 0;
      _selectedUser = null;
      _tradeData = null;
      _selectedCollectionId = null;
      _showAllSurpluses = false;
      _offeredQuantities.clear();
      _requestedQuantities.clear();
      _optionsError = null;
    });
  }

  Future<void> _continueFromRecipient() async {
    if (_selectedUser == null || _isLoadingOptions) {
      return;
    }

    setState(() {
      _step = 1;
      _isLoadingOptions = true;
      _optionsError = null;
      _tradeData = null;
      _selectedCollectionId = null;
      _showAllSurpluses = false;
      _offeredQuantities.clear();
      _requestedQuantities.clear();
    });

    try {
      final data = await _manualTradeService.loadOptions(
        otherUserId: _selectedUser!.uid,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _tradeData = data;

        if (data.collections.isEmpty) {
          _selectedCollectionId = null;
        } else {
          final preferredCollection = data.collections.firstWhere(
            (entry) => entry.hasSuggestedTrade,
            orElse: () => data.collections.firstWhere(
              (entry) => entry.hasAllSurplusTrade,
              orElse: () => data.collections.first,
            ),
          );

          _selectedCollectionId = preferredCollection.collection.id;
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _optionsError = AppLocalizations.of(
          context,
        )!.tradeManualOptionsError(error.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOptions = false;
        });
      }
    }
  }

  void _setQuantity({
    required ManualTradeItemOption option,
    required bool offered,
    required int quantity,
  }) {
    final normalizedQuantity = quantity
        .clamp(0, option.availableQuantity)
        .toInt();

    final target = offered ? _offeredQuantities : _requestedQuantities;

    setState(() {
      if (normalizedQuantity <= 0) {
        target.remove(option.key);
      } else {
        target[option.key] = normalizedQuantity;
      }
    });
  }

  int _quantityFor({
    required ManualTradeItemOption option,
    required bool offered,
  }) {
    final source = offered ? _offeredQuantities : _requestedQuantities;

    return source[option.key] ?? 0;
  }

  int get _selectedOfferedItemCount =>
      _offeredQuantities.values.where((quantity) => quantity > 0).length;

  int get _selectedRequestedItemCount =>
      _requestedQuantities.values.where((quantity) => quantity > 0).length;

  int get _selectedOfferedTotal =>
      _offeredQuantities.values.fold(0, (total, quantity) => total + quantity);

  int get _selectedRequestedTotal => _requestedQuantities.values.fold(
    0,
    (total, quantity) => total + quantity,
  );

  bool get _canReview =>
      _selectedOfferedTotal > 0 && _selectedRequestedTotal > 0;

  ManualTradeCollectionOptions? get _selectedCollection {
    final data = _tradeData;
    final id = _selectedCollectionId;

    if (data == null || id == null) {
      return null;
    }

    for (final entry in data.collections) {
      if (entry.collection.id == id) {
        return entry;
      }
    }

    return null;
  }

  List<ManualTradeItemOption> _visibleOfferItems(
    ManualTradeCollectionOptions collection,
  ) {
    return _showAllSurpluses
        ? collection.allCurrentUserCanOffer
        : collection.currentUserCanOffer;
  }

  List<ManualTradeItemOption> _visibleRequestItems(
    ManualTradeCollectionOptions collection,
  ) {
    return _showAllSurpluses
        ? collection.allOtherUserCanOffer
        : collection.otherUserCanOffer;
  }

  void _setShowAllSurpluses(bool value) {
    final collection = _selectedCollection;

    setState(() {
      _showAllSurpluses = value;

      if (!value && collection != null) {
        final visibleOfferKeys = collection.currentUserCanOffer
            .map((option) => option.key)
            .toSet();
        final visibleRequestKeys = collection.otherUserCanOffer
            .map((option) => option.key)
            .toSet();

        _offeredQuantities.removeWhere(
          (key, quantity) => !visibleOfferKeys.contains(key),
        );
        _requestedQuantities.removeWhere(
          (key, quantity) => !visibleRequestKeys.contains(key),
        );
      }
    });
  }

  List<ManualTradeItemOption> _selectedOptions({required bool offered}) {
    final data = _tradeData;

    if (data == null) {
      return [];
    }

    final source = offered ? _offeredQuantities : _requestedQuantities;
    final options = offered ? data.allOfferItems : data.allRequestItems;

    return options
        .where((option) => (source[option.key] ?? 0) > 0)
        .toList(growable: false);
  }

  List<TradeItem> _tradeItems({required bool offered}) {
    final source = offered ? _offeredQuantities : _requestedQuantities;

    return _selectedOptions(offered: offered)
        .map(
          (option) => TradeItem(
            collectionId: option.collection.id,
            itemId: option.item.id,
            itemNumber: option.item.number,
            quantity: source[option.key] ?? 1,
          ),
        )
        .toList(growable: false);
  }

  void _reviewOffer() {
    final localizations = AppLocalizations.of(context)!;

    if (!_canReview) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.tradeManualChooseAtLeastOneEach)),
      );
      return;
    }

    setState(() {
      _step = 2;
    });
  }

  Future<void> _sendOffer() async {
    final user = _selectedUser;

    if (user == null || _isSending) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    final offeredItems = _tradeItems(offered: true);
    final requestedItems = _tradeItems(offered: false);

    if (offeredItems.isEmpty || requestedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.tradeManualChooseAtLeastOneEach)),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final tradeId = await _tradeService.createTrade(
        receiverId: user.uid,
        offeredItems: offeredItems,
        requestedItems: requestedItems,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.tradeManualOfferCreated)),
      );

      Navigator.of(context).pop(tradeId);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localizedSendError(error, localizations))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  String _localizedSendError(Object error, AppLocalizations localizations) {
    if (error is TradeInventoryUnavailableException) {
      return error.side == TradeInventorySide.sender
          ? localizations.tradeManualYourInventoryUnavailable(error.itemNumber)
          : localizations.tradeManualTheirInventoryUnavailable(
              error.itemNumber,
            );
    }

    if (error is TradeCatalogItemUnavailableException) {
      return localizations.tradeManualCatalogItemUnavailable(error.itemNumber);
    }

    if (error is ArgumentError) {
      return localizations.tradeManualInvalidOffer;
    }

    return localizations.tradeManualOfferError(error.toString());
  }

  Future<bool> _handleBack() async {
    if (_step == 2) {
      setState(() {
        _step = 1;
      });
      return false;
    }

    if (_step == 1) {
      setState(() {
        _step = 0;
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }

        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.tradeNewTrade),
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () async {
              final canPop = await _handleBack();

              if (canPop && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Column(
          children: [
            _TradeStepHeader(currentStep: _step),
            const Divider(height: 1),
            Expanded(child: _buildStep(localizations)),
          ],
        ),
        bottomNavigationBar: _buildBottomActions(localizations),
      ),
    );
  }

  Widget _buildStep(AppLocalizations localizations) {
    switch (_step) {
      case 0:
        return _buildRecipientStep(localizations);
      case 1:
        return _buildItemsStep(localizations);
      case 2:
        return _buildSummaryStep(localizations);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRecipientStep(AppLocalizations localizations) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          localizations.tradeRecipient,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          localizations.tradeManualChooseRecipientDescription,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (_selectedUser == null) ...[
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: localizations.tradeSearchUserHint,
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: localizations.clearSearch,
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              _searchDebounce?.cancel();
              _searchUsers(value.trim());
            },
          ),
          const SizedBox(height: 10),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchError != null)
            _MessageCard(icon: Icons.error_outline, message: _searchError!)
          else if (_hasSearched && _searchResults.isEmpty)
            _MessageCard(
              icon: Icons.person_search_outlined,
              message: localizations.tradeNoUsersMatch,
            )
          else
            ..._searchResults.map(
              (user) => _UserSelectionCard(
                user: user,
                onTap: () => _selectUser(user),
              ),
            ),
        ] else
          _SelectedUserCard(user: _selectedUser!, onChange: _changeRecipient),
      ],
    );
  }

  Widget _buildItemsStep(AppLocalizations localizations) {
    if (_isLoadingOptions) {
      return _LoadingState(message: localizations.tradeManualLoadingOptions);
    }

    if (_optionsError != null) {
      return _ErrorState(
        message: _optionsError!,
        onRetry: _continueFromRecipient,
      );
    }

    final data = _tradeData;

    if (data == null || data.collections.isEmpty) {
      return _EmptyOptionsState(
        title: data?.hasCommonCollections == true
            ? localizations.tradeManualNoAvailableItems
            : localizations.tradeManualNoCommonCollections,
        description: data?.hasCommonCollections == true
            ? localizations.tradeManualNeedsBothDirections
            : localizations.tradeManualNoCommonCollectionsDescription,
        onChangeRecipient: _changeRecipient,
      );
    }

    if (!data.hasOfferItems || !data.hasRequestItems) {
      return _EmptyOptionsState(
        title: localizations.tradeManualNoAvailableItems,
        description: localizations.tradeManualNeedsBothDirections,
        onChangeRecipient: _changeRecipient,
      );
    }

    final selectedCollection = _selectedCollection;

    if (selectedCollection == null) {
      return _EmptyOptionsState(
        title: localizations.tradeManualNoAvailableItems,
        description: localizations.tradeManualNeedsBothDirections,
        onChangeRecipient: _changeRecipient,
      );
    }

    final visibleOfferItems = _visibleOfferItems(selectedCollection);
    final visibleRequestItems = _visibleRequestItems(selectedCollection);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SelectedUserCard(
          user: _selectedUser!,
          onChange: _changeRecipient,
          compact: true,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: selectedCollection.collection.id,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: localizations.tradeManualChooseCollection,
            prefixIcon: const Icon(Icons.collections_bookmark_outlined),
            border: const OutlineInputBorder(),
          ),
          items: data.collections
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.collection.id,
                  child: Text(
                    entry.collection.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(growable: false),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedCollectionId = value;
              _showAllSurpluses = false;
              _offeredQuantities.clear();
              _requestedQuantities.clear();
            });
          },
        ),
        const SizedBox(height: 8),
        Text(
          localizations.tradeManualSelectionsRemainAcrossCollections,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: SwitchListTile.adaptive(
            value: _showAllSurpluses,
            onChanged: _setShowAllSurpluses,
            title: Text(localizations.tradeManualShowAllSurpluses),
            subtitle: Text(
              _showAllSurpluses
                  ? localizations.tradeManualAllSurplusesDescription
                  : localizations.tradeManualSuggestedSurplusesDescription,
            ),
            secondary: Icon(
              _showAllSurpluses
                  ? Icons.filter_alt_off_outlined
                  : Icons.auto_awesome_outlined,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _ItemSelectionSection(
          title: localizations.tradeIAmOffering,
          icon: Icons.upload_rounded,
          selectedCount: _selectedOfferedItemCount,
          items: visibleOfferItems,
          emptyMessage: _showAllSurpluses
              ? localizations.tradeManualNoOfferedItemsInCollection
              : localizations.tradeManualNoSuggestedOfferedItemsInCollection,
          quantityFor: (option) => _quantityFor(option: option, offered: true),
          onQuantityChanged: (option, quantity) =>
              _setQuantity(option: option, offered: true, quantity: quantity),
        ),
        const SizedBox(height: 20),
        _ItemSelectionSection(
          title: localizations.tradeIWant,
          icon: Icons.download_rounded,
          selectedCount: _selectedRequestedItemCount,
          items: visibleRequestItems,
          emptyMessage: _showAllSurpluses
              ? localizations.tradeManualNoRequestedItemsInCollection
              : localizations.tradeManualNoSuggestedRequestedItemsInCollection,
          quantityFor: (option) => _quantityFor(option: option, offered: false),
          onQuantityChanged: (option, quantity) =>
              _setQuantity(option: option, offered: false, quantity: quantity),
        ),
      ],
    );
  }

  Widget _buildSummaryStep(AppLocalizations localizations) {
    final user = _selectedUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          localizations.tradeSummaryTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _SummaryRecipientCard(user: user),
        const SizedBox(height: 20),
        _TradeSummarySelection(
          title: localizations.tradeManualSummaryOffering,
          icon: Icons.upload_rounded,
          options: _selectedOptions(offered: true),
          quantities: _offeredQuantities,
        ),
        const SizedBox(height: 20),
        _TradeSummarySelection(
          title: localizations.tradeManualSummaryRequesting,
          icon: Icons.download_rounded,
          options: _selectedOptions(offered: false),
          quantities: _requestedQuantities,
        ),
      ],
    );
  }

  Widget _buildBottomActions(AppLocalizations localizations) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            if (_step > 0) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSending
                      ? null
                      : () {
                          setState(() {
                            _step--;
                          });
                        },
                  icon: const Icon(Icons.arrow_back),
                  label: Text(localizations.tradeManualBack),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: _step == 0 ? 1 : 2,
              child: FilledButton.icon(
                onPressed: _primaryActionEnabled ? _primaryAction : null,
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_primaryActionIcon),
                label: Text(_primaryActionLabel(localizations)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _primaryActionEnabled {
    if (_isSending || _isLoadingOptions) {
      return false;
    }

    switch (_step) {
      case 0:
        return _selectedUser != null;
      case 1:
        return _canReview;
      case 2:
        return _canReview;
      default:
        return false;
    }
  }

  VoidCallback get _primaryAction {
    switch (_step) {
      case 0:
        return () {
          _continueFromRecipient();
        };
      case 1:
        return _reviewOffer;
      case 2:
        return () {
          _sendOffer();
        };
      default:
        return () {};
    }
  }

  IconData get _primaryActionIcon {
    switch (_step) {
      case 0:
        return Icons.arrow_forward;
      case 1:
        return Icons.fact_check_outlined;
      case 2:
        return Icons.send;
      default:
        return Icons.arrow_forward;
    }
  }

  String _primaryActionLabel(AppLocalizations localizations) {
    switch (_step) {
      case 0:
        return localizations.continueButton;
      case 1:
        return localizations.tradeManualReviewOffer;
      case 2:
        return _isSending
            ? localizations.tradeManualSendingOffer
            : localizations.tradeManualSendOffer;
      default:
        return localizations.continueButton;
    }
  }

  static String _initials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    return '${parts.first.characters.first}'
            '${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _TradeStepHeader extends StatelessWidget {
  final int currentStep;

  const _TradeStepHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final steps = [
      localizations.tradeManualStepRecipient,
      localizations.tradeManualStepItems,
      localizations.tradeManualStepSummary,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: List.generate(steps.length, (index) {
          final active = index <= currentStep;

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: active
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: active
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    steps[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: index == currentStep
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (index < steps.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _UserSelectionCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onTap;

  const _UserSelectionCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final displayName = user.displayName.trim().isEmpty
        ? localizations.unnamedUser
        : user.displayName.trim();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.photoUrl.trim().isEmpty
              ? null
              : NetworkImage(user.photoUrl),
          child: user.photoUrl.trim().isEmpty
              ? Text(_CreateTradePageState._initials(displayName))
              : null,
        ),
        title: Text(displayName),
        subtitle: Text(user.email),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SelectedUserCard extends StatelessWidget {
  final UserProfile user;
  final VoidCallback onChange;
  final bool compact;

  const _SelectedUserCard({
    required this.user,
    required this.onChange,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final displayName = user.displayName.trim().isEmpty
        ? localizations.unnamedUser
        : user.displayName.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        dense: compact,
        leading: CircleAvatar(
          backgroundImage: user.photoUrl.trim().isEmpty
              ? null
              : NetworkImage(user.photoUrl),
          child: user.photoUrl.trim().isEmpty
              ? Text(_CreateTradePageState._initials(displayName))
              : null,
        ),
        title: Text(displayName),
        subtitle: compact ? null : Text(user.email),
        trailing: TextButton(
          onPressed: onChange,
          child: Text(localizations.tradeManualChangeRecipient),
        ),
      ),
    );
  }
}

class _ItemSelectionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final int selectedCount;
  final List<ManualTradeItemOption> items;
  final String emptyMessage;
  final int Function(ManualTradeItemOption option) quantityFor;
  final void Function(ManualTradeItemOption option, int quantity)
  onQuantityChanged;

  const _ItemSelectionSection({
    required this.title,
    required this.icon,
    required this.selectedCount,
    required this.items,
    required this.emptyMessage,
    required this.quantityFor,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  localizations.tradeManualSelectedItems(selectedCount),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(emptyMessage)
            else
              ...items.map((option) {
                final quantity = quantityFor(option);

                return _SelectableTradeItemTile(
                  option: option,
                  quantity: quantity,
                  onQuantityChanged: (value) {
                    onQuantityChanged(option, value);
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SelectableTradeItemTile extends StatelessWidget {
  final ManualTradeItemOption option;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _SelectableTradeItemTile({
    required this.option,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final selected = quantity > 0;
    final item = option.item;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
        color: selected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.30)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (value) {
                onQuantityChanged(value == true ? 1 : 0);
              },
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name.trim().isEmpty
                        ? '#${item.number}'
                        : '#${item.number} · ${item.name}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    localizations.tradeManualAvailableQuantity(
                      option.availableQuantity,
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (selected)
              _QuantitySelector(
                quantity: quantity,
                maximum: option.availableQuantity,
                onChanged: onQuantityChanged,
              ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maximum;
  final ValueChanged<int> onChanged;

  const _QuantitySelector({
    required this.quantity,
    required this.maximum,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: quantity <= 0 ? null : () => onChanged(quantity - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: quantity >= maximum ? null : () => onChanged(quantity + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _TradeSummarySelection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ManualTradeItemOption> options;
  final Map<String, int> quantities;

  const _TradeSummarySelection({
    required this.title,
    required this.icon,
    required this.options,
    required this.quantities,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ManualTradeItemOption>>{};

    for (final option in options) {
      grouped
          .putIfAbsent(option.collection.id, () => <ManualTradeItemOption>[])
          .add(option);
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final entry in grouped.entries) ...[
              Text(
                entry.value.first.collection.name,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              ...entry.value.map((option) {
                final quantity = quantities[option.key] ?? 1;
                final item = option.item;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          item.name.trim().isEmpty
                              ? '#${item.number}'
                              : '#${item.number} · ${item.name}',
                        ),
                      ),
                      if (quantity > 1) Text('×$quantity'),
                    ],
                  ),
                );
              }),
              if (entry.key != grouped.keys.last) const Divider(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRecipientCard extends StatelessWidget {
  final UserProfile user;

  const _SummaryRecipientCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final displayName = user.displayName.trim().isEmpty
        ? localizations.unnamedUser
        : user.displayName.trim();

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(localizations.tradeManualSummaryRecipient),
        subtitle: Text(displayName),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _MessageCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  final String message;

  const _LoadingState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOptionsState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onChangeRecipient;

  const _EmptyOptionsState({
    required this.title,
    required this.description,
    required this.onChangeRecipient,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_horiz, size: 60),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onChangeRecipient,
              icon: const Icon(Icons.person_search_outlined),
              label: Text(localizations.tradeManualChangeRecipient),
            ),
          ],
        ),
      ),
    );
  }
}
