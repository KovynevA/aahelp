import 'dart:ui';

import 'package:flutter/material.dart';

// Стиль полей ввода
class TextFieldStyleWidget extends StatelessWidget {
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  final double sizewidth;
  final double sizeheight;
  final Decoration? decoration;
  final String? text;
  const TextFieldStyleWidget({
    super.key,
    this.onChanged,
    this.controller,
    this.sizeheight = 50,
    this.sizewidth = 105,
    this.decoration,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizewidth,
      height: sizeheight,
      decoration: decoration ??
          BoxDecoration(
              border: Border.all(width: 1.5, color: Colors.brown),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white24,
                  blurRadius: 2.0,
                  offset: Offset(2.0, 1.0),
                )
              ]),
      child: TextFormField(
        textAlignVertical: TextAlignVertical.center,
        controller: controller,
        maxLines: null,
        expands: true,
        onChanged: onChanged,
        style: AppTextStyle.valuesstyle,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: AppTextStyle.valuesstyle,
          border: InputBorder.none,
          contentPadding: EdgeInsets.fromLTRB(8.0, 2.0, 0, 2.0),
        ),
      ),
    );
  }
}

// Виджет стиля поля ввода текста
class AnimatedTextFieldStyleWidget extends StatefulWidget {
  final void Function(String)? onChanged;
  final void Function(bool)? onFocusChanged;
  final TextEditingController? controller;
  final double? sizewidth;
  final double? sizeheight;
  final Decoration? decoration;
  final String? text;
  final double heightCoeff;

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

  @override
  State<AnimatedTextFieldStyleWidget> createState() =>
      _AnimatedTextFieldStyleWidgetState();
}

class _AnimatedTextFieldStyleWidgetState
    extends State<AnimatedTextFieldStyleWidget> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: _isFocused
          ? MediaQuery.of(context).size.width * 0.9
          : widget.sizewidth,
      height: _isFocused
          ? MediaQuery.of(context).size.height * widget.heightCoeff
          : widget.sizeheight,
      duration: const Duration(milliseconds: 200),
      decoration: widget.decoration ??
          BoxDecoration(
            border: Border.all(width: 1.5, color: Colors.brown),
            boxShadow: const [
              BoxShadow(
                color: Colors.white24,
                blurRadius: 2.0,
                offset: Offset(2.0, 1.0),
              )
            ],
          ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
          if (widget.onFocusChanged != null) {
            widget.onFocusChanged!(hasFocus);
          }
        },
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          controller: widget.controller,
          maxLines: null,
          expands: true,
          onChanged: widget.onChanged,
          style: AppTextStyle.valuesstyle,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: widget.text,
            labelStyle: AppTextStyle.spantextstyle,
            border: InputBorder.none,
            contentPadding: EdgeInsets.fromLTRB(8.0, 2.0, 0, 2.0),
          ),
        ),
      ),
    );
  }
}

// Меню выбора DropDownButton
class TreasureDropdownButton extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final TextStyle styleText;
  final Decoration? decoration;

  const TreasureDropdownButton({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.styleText,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration ??
          const BoxDecoration(
            border: Border.fromBorderSide(BorderSide.none),
          ),
      child: DropdownButton<String>(
        underline: Container(),
        menuMaxHeight: MediaQuery.of(context).size.height * 0.5,
        dropdownColor: AppColor.cardColor,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        value: value,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: styleText,
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// плавающие кнопки
class CustomFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CustomFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: UniqueKey(),
      backgroundColor:
          AppColor.defaultColor.withValues(colorSpace: ColorSpace.sRGB),
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}

// Стиль кнопок
abstract class AppButtonStyle {
  static final ButtonStyle iconButton = ButtonStyle(
    backgroundColor:
        WidgetStateProperty.all(const Color.fromARGB(185, 120, 155, 131)),
    shadowColor: WidgetStateProperty.all(Colors.grey),
    elevation: WidgetStateProperty.all(10.0),
    // fixedSize: MaterialStateProperty.all(const Size(75, 25)),
    side: WidgetStateProperty.all(
      const BorderSide(width: 2.0, color: Colors.brown),
    ),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
  );

  static final ButtonStyle dialogButton = ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white54),
    shadowColor: WidgetStateProperty.all(Colors.grey),
    elevation: WidgetStateProperty.all(10.0),
    //fixedSize: MaterialStateProperty.all(const Size(140, 30)),
    shape: WidgetStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    ),
  );
}

abstract class AppTextStyle {
  static const menutextstyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    shadows: [
      Shadow(
        color: Colors.blueGrey,
        blurRadius: 2.0,
        offset: Offset(1.0, 0.0),
      )
    ],
  );

  static const valuesstyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const booktextstyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const minimalsstyle = TextStyle(
    color: Colors.brown,
    fontWeight: FontWeight.bold,
    //fontStyle: FontStyle.italic,
    fontSize: 12,
  );

  static const spantextstyle = TextStyle(
    color: Colors.brown,
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.italic,
    fontSize: 14,
  );
}

abstract class AppColor {
  static const defaultColor = Color.fromARGB(255, 225, 218, 245);
  static const backgroundColor = Color.fromRGBO(223, 234, 232, 1);
  static const cardColor = Color.fromRGBO(235, 218, 199, 1);
  static const deleteCardColor = Color.fromARGB(255, 191, 161, 227);
}

abstract class Decor {
  static final decorDropDownButton = BoxDecoration(
    gradient: LinearGradient(colors: [
      AppColor.cardColor,
      AppColor.backgroundColor,
    ]),
    boxShadow: <BoxShadow>[
      BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
          blurRadius: 0) //blur radius of shadow
    ],
    border: Border.all(
      width: 2.0,
      color: AppColor.deleteCardColor,
    ),
  );

  static final decorTextField = BoxDecoration(
    border: Border.all(width: 1.5, color: AppColor.deleteCardColor),
    gradient: const LinearGradient(colors: [
      AppColor.cardColor,
      AppColor.backgroundColor,
    ]),
    boxShadow: const <BoxShadow>[
      BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.57), //shadow for button
          blurRadius: 5) //blur radius of shadow
    ],
  );
}

class MultilineDropdownMenuItem<T> extends DropdownMenuItem<T> {
  final String text;

  MultilineDropdownMenuItem({
    super.key,
    required T value,
    required this.text,
  }) : super(
          value: value,
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        );
}

class TextAndIconRowWidget extends StatelessWidget {
  final Icon icon;
  final String text;

  const TextAndIconRowWidget(
      {super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.98,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          icon,
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.valuesstyle,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

// Виджет Text
class BeautifulText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool withShadow;
  final bool withGradient;
  final bool withAnimation;
  final TextAlign textAlign;

  const BeautifulText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.color = Colors.blueAccent,
    this.fontWeight = FontWeight.bold,
    this.withShadow = true,
    this.withGradient = false,
    this.withAnimation = false,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Center(
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: withGradient ? Colors.white : color,
          shadows: withShadow
              ? [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(2, 2),
                  ),
                ]
              : null,
        ),
      ),
    );

    final content = withGradient
        ? ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                color,
                Colors.purpleAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: textWidget,
          )
        : textWidget;

    return withAnimation
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(
                  scale: value,
                  child: child,
                ),
              );
            },
            child: content,
          )
        : content;
  }
}
