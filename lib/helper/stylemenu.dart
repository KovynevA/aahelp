import 'dart:ui';

import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TextFieldStyleWidget extends StatelessWidget {
  const TextFieldStyleWidget({
    super.key,
    this.onChanged,
    this.controller,
    this.sizeheight = 52,
    this.sizewidth = 180,
    this.decoration,
    this.text,
  });

  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final double sizewidth;
  final double sizeheight;
  final Decoration? decoration;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sizewidth,
      height: sizeheight,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: text,
          prefixIcon: const Icon(Icons.edit_outlined),
          filled: true,
        ),
      ),
    );
  }
}

class AnimatedTextFieldStyleWidget extends StatefulWidget {
  const AnimatedTextFieldStyleWidget({
    super.key,
    this.onChanged,
    this.onFocusChanged,
    this.controller,
    this.sizeheight,
    this.sizewidth,
    this.decoration,
    this.text,
    this.heightCoeff = 0.1,
  });

  final void Function(String)? onChanged;
  final void Function(bool)? onFocusChanged;
  final TextEditingController? controller;
  final double? sizewidth;
  final double? sizeheight;
  final Decoration? decoration;
  final String? text;
  final double heightCoeff;

  @override
  State<AnimatedTextFieldStyleWidget> createState() =>
      _AnimatedTextFieldStyleWidgetState();
}

class _AnimatedTextFieldStyleWidgetState
    extends State<AnimatedTextFieldStyleWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: _isFocused ? media.width * 0.92 : widget.sizewidth,
      height: _isFocused
          ? media.height * widget.heightCoeff
          : (widget.sizeheight ?? 54),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
          widget.onFocusChanged?.call(hasFocus);
        },
        child: TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          maxLines: null,
          expands: true,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.text,
            prefixIcon: const Icon(Icons.edit_note_rounded),
            alignLabelWithHint: true,
          ),
        ),
      ),
    );
  }
}

class TreasureDropdownButton extends StatelessWidget {
  const TreasureDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.styleText,
    this.decoration,
  });

  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final TextStyle styleText;
  final Decoration? decoration;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration ??
          BoxDecoration(
            color: context.appPalette.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: context.appPalette.border),
          ),
      child: DropdownButton<String>(
        underline: const SizedBox.shrink(),
        isExpanded: true,
        menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownColor: context.appPalette.surface,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        value: value,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: styleText),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: UniqueKey(),
      backgroundColor: context.appPalette.surface,
      foregroundColor: Theme.of(context).colorScheme.primary,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

abstract class AppButtonStyle {
  static final ButtonStyle iconButton = FilledButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
  );

  static final ButtonStyle dialogButton = ButtonStyle(
    padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  );
}

abstract class AppTextStyle {
  static const menutextstyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );

  static const valuesstyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 16,
  );

  static const booktextstyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.5,
  );

  static const minimalsstyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  static const spantextstyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 14,
    height: 1.4,
  );
}

abstract class AppColor {
  static const defaultColor = Color(0xFFE6F0EC);
  static const backgroundColor = Color(0xFFF4F8FF);
  static const cardColor = Color(0xFFFDFEFF);
  static const deleteCardColor = Color(0xFFD3DFE6);
}

abstract class Decor {
  static final decorDropDownButton = BoxDecoration(
    color: AppColor.cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColor.deleteCardColor),
  );

  static final decorTextField = BoxDecoration(
    color: AppColor.cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColor.deleteCardColor),
  );
}

class MultilineDropdownMenuItem<T> extends DropdownMenuItem<T> {
  MultilineDropdownMenuItem({
    super.key,
    required T value,
    required String text,
  }) : super(
          value: value,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        );
}

class AppPanel extends StatelessWidget {
  const AppPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null
                ? palette.surface.withValues(alpha: 0.9)
                : null,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: palette.border.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: palette.shadow,
                blurRadius: 22,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class AppMetricCard extends StatelessWidget {
  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accent,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;
    final chipColor = accent ?? palette.accent;

    return AppPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (icon != null)
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: chipColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: chipColor),
            ),
          if (icon != null) const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TextAndIconRowWidget extends StatelessWidget {
  const TextAndIconRowWidget({
    super.key,
    required this.icon,
    required this.text,
  });

  final Icon icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.accentSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconTheme(
              data: IconThemeData(
                color: palette.accent,
                size: 18,
              ),
              child: icon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text.trim(),
              style: theme.textTheme.bodyLarge,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

class BeautifulText extends StatelessWidget {
  const BeautifulText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = Colors.blueAccent,
    this.fontWeight = FontWeight.bold,
    this.withShadow = false,
    this.withGradient = false,
    this.withAnimation = false,
    this.textAlign = TextAlign.center,
  });

  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool withShadow;
  final bool withGradient;
  final bool withAnimation;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    Widget child = Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: withGradient ? Colors.white : color,
            shadows: withShadow
                ? [
                    Shadow(
                      blurRadius: 12,
                      color: palette.shadow,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
    );

    if (withGradient) {
      child = ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [
            palette.heroStart,
            palette.heroEnd,
          ],
        ).createShader(bounds),
        child: child,
      );
    }

    if (!withAnimation) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: const Duration(milliseconds: 380),
      builder: (context, value, animatedChild) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: value,
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
