import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// The pill-shaped input used on Home and in a conversation.
///
/// DESIGN.md: a single pill field with a soft tonal fill and no heavy borders,
/// with a gentle prompt as placeholder. The microphone is reserved for a future
/// release (PRD §9) — pass [showMicrophone] only once voice actually works.
class ConversationInput extends StatefulWidget {
  const ConversationInput({
    super.key,
    required this.hintText,
    required this.onSubmit,
    this.controller,
    this.enabled = true,
    this.autofocus = false,
    this.showMicrophone = false,
  });

  final String hintText;

  /// Called with the trimmed, non-empty message.
  final ValueChanged<String> onSubmit;

  final TextEditingController? controller;
  final bool enabled;
  final bool autofocus;
  final bool showMicrophone;

  @override
  State<ConversationInput> createState() => _ConversationInputState();
}

class _ConversationInputState extends State<ConversationInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  bool _ownsController = false;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller.addListener(_handleChanged);
    _canSend = _controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _handleChanged() {
    final canSend = _controller.text.trim().isNotEmpty;
    if (canSend != _canSend) setState(() => _canSend = canSend);
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty || !widget.enabled) return;
    widget.onSubmit(value);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: AppRadius.interactiveRadius,
      ),
      padding: const EdgeInsets.only(
        left: AppSpacing.stackLg,
        right: AppSpacing.stackSm,
        top: AppSpacing.stackSm,
        bottom: AppSpacing.stackSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: context.text.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintText: widget.hintText,
                hintStyle: context.text.bodyMedium?.copyWith(
                  color: colors.outline,
                ),
              ),
            ),
          ),
          if (widget.showMicrophone)
            IconButton(
              onPressed: widget.enabled ? () {} : null,
              icon: const Icon(Icons.mic_none_rounded),
              color: colors.outline,
            ),
          _SendButton(enabled: _canSend && widget.enabled, onTap: _submit),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.curve,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: enabled ? colors.primary : colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: enabled ? onTap : null,
        padding: EdgeInsets.zero,
        icon: Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: enabled ? colors.onPrimary : colors.outline,
        ),
      ),
    );
  }
}
