import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool automaticallyImplyLeading;
  final VoidCallback? onLeadingPressed;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final String? subtitle;
  final Widget? flexibleSpace;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
    this.onLeadingPressed,
    this.bottom,
    this.showBackButton = false,
    this.subtitle,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? colorScheme.onBackground,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading && !showBackButton,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      systemOverlayStyle: _getSystemOverlayStyle(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Volver',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Padding(padding: const EdgeInsets.only(right: 8), child: action);
      }
      return action;
    }).toList();
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
  }

  @override
  Size get preferredSize {
    double height = kToolbarHeight;
    if (bottom != null) {
      height += bottom!.preferredSize.height;
    }
    return Size.fromHeight(height);
  }
}

// AppBar especializada para pantallas con búsqueda
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchClear;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  const SearchAppBar({
    Key? key,
    required this.title,
    this.hintText = 'Buscar...',
    this.onSearchChanged,
    this.onSearchClear,
    this.actions,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _searchFocus.requestFocus();
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
    widget.onSearchClear?.call();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching ? _buildSearchField() : Text(widget.title),
      automaticallyImplyLeading:
          widget.automaticallyImplyLeading && !_isSearching,
      leading:
          _isSearching
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _stopSearch,
              )
              : null,
      actions:
          _isSearching
              ? [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged?.call('');
                    },
                  ),
              ]
              : [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _startSearch,
                ),
                ...?widget.actions,
              ],
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      focusNode: _searchFocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
        ),
      ),
      style: Theme.of(context).textTheme.titleLarge,
      onChanged: widget.onSearchChanged,
    );
  }
}

// AppBar con gradiente
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Gradient gradient;
  final double elevation;
  final bool automaticallyImplyLeading;

  const GradientAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    required this.gradient,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: centerTitle,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: elevation,
        automaticallyImplyLeading: automaticallyImplyLeading,
        leading: leading,
        actions: actions,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar minimalista
class MinimalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const MinimalAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.onBackPressed,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// AppBar con tabs
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Tab> tabs;
  final TabController? controller;
  final List<Widget>? actions;

  const TabAppBar({
    Key? key,
    required this.title,
    required this.tabs,
    this.controller,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions,
      bottom: TabBar(
        controller: controller,
        tabs: tabs,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(kToolbarHeight + kTextTabBarHeight);
  }
}
