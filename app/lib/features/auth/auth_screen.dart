import 'package:flutter/material.dart';
import 'package:sc_synthesis/core/api/auth_manager.dart';
import 'package:sc_synthesis/core/api/api_client.dart';

/// Auth screen — RSI login via Rust server proxy
class AuthScreen extends StatefulWidget {
  final AuthManager authManager;

  const AuthScreen({super.key, required this.authManager});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _serverOnline = false;
  bool _checkingServer = true;

  @override
  void initState() {
    super.initState();
    widget.authManager.addListener(_onAuthChanged);
    _checkServerStatus();
  }

  @override
  void dispose() {
    widget.authManager.removeListener(_onAuthChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _checkingServer = true;
    });
    try {
      // Ping the server health endpoint
      await ApiClient().healthCheck();
      if (mounted) {
        setState(() {
          _serverOnline = true;
          _checkingServer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverOnline = false;
          _checkingServer = false;
        });
      }
    }
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) return;

    await widget.authManager.login(username, password);
  }

  Future<void> _handleLogout() async {
    await widget.authManager.logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = widget.authManager;

    return Scaffold(
      appBar: AppBar(title: const Text('SC:Synthesis'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Server status indicator
              _buildServerStatus(theme),
              const SizedBox(height: 24),
              // Main content
              auth.isAuthenticated
                  ? _buildAuthenticatedView(theme, auth)
                  : _buildLoginForm(theme, auth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerStatus(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _checkingServer
            ? theme.colorScheme.onSurface.withValues(alpha: 0.03)
            : _serverOnline
                ? Colors.green.withValues(alpha: 0.06)
                : theme.colorScheme.error.withValues(alpha: 0.06),
        border: Border.all(
          color: _checkingServer
              ? theme.colorScheme.onSurface.withValues(alpha: 0.08)
              : _serverOnline
                  ? Colors.green.withValues(alpha: 0.2)
                  : theme.colorScheme.error.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _checkingServer
                  ? Colors.grey
                  : _serverOnline
                      ? Colors.green
                      : theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _checkingServer
                ? 'Checking server...'
                : _serverOnline
                    ? 'Server: Connected (localhost:3001)'
                    : 'Server: Disconnected',
            style: theme.textTheme.labelSmall?.copyWith(
              color: _checkingServer
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : _serverOnline
                      ? Colors.green.shade700
                      : theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!_checkingServer && !_serverOnline) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _checkServerStatus,
              child: Icon(
                Icons.refresh,
                size: 14,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuthenticatedView(ThemeData theme, AuthManager auth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.check_circle_outline,
            size: 44,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text('Connected', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Signed in as ${auth.username}',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your fleet data is being synced from RSI.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Disconnect RSI Account'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(
                color: theme.colorScheme.error.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(ThemeData theme, AuthManager auth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary.withValues(alpha: 0.08),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.person_outline,
            size: 44,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Connect RSI Account',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to sync your fleet, pledges, and org data.\nYour credentials never leave your device.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Username field
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            labelText: 'RSI Username / Handle',
            prefixIcon: const Icon(Icons.person),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textInputAction: TextInputAction.next,
          autocorrect: false,
          enableSuggestions: false,
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 8),

        // Error message
        if (auth.status == AuthStatus.error)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline,
                    size: 16, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    auth.errorMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 2FA message
        if (auth.status == AuthStatus.requires2fa)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.security_outlined,
                    size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Two-factor authentication required.\nCheck your authenticator app.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Login button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: auth.status == AuthStatus.authenticating
                ? null
                : _handleLogin,
            icon: auth.status == AuthStatus.authenticating
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.login),
            label: Text(
              auth.status == AuthStatus.authenticating
                  ? 'Signing in...'
                  : 'Sign in with RSI',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
