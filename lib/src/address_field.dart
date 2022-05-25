import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class VscAddressLookupField extends StatefulWidget {
  const VscAddressLookupField({
    Key? key,
    required this.googlePlacesApiKey,
    required this.poweredByGoogleLogo,
    this.textFieldConfiguration = const TextFieldConfiguration(),
    this.readOnly = false,
    this.initialValue,
  }) : super(key: key);

  final String googlePlacesApiKey;
  final bool readOnly;
  final String? initialValue;
  final Widget poweredByGoogleLogo;

  /// The configuration of the [TextField](https://docs.flutter.io/flutter/material/TextField-class.html)
  /// that the VscAddressLookupField widget displays
  final TextFieldConfiguration textFieldConfiguration;

  @override
  State<VscAddressLookupField> createState() => _VscAddressLookupFieldState();
}

class _VscAddressLookupFieldState extends State<VscAddressLookupField> {
  Uuid? _sessionToken;

  List<_AutocompleteResult> _results = [
    _AutocompleteResult('value1'),
    _AutocompleteResult('value2'),
  ];

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<_AutocompleteResult>(
      displayStringForOption: (result) => result.toString(),
      optionsViewBuilder: (context, onSelected, options) {
        return _AutocompleteOptions<_AutocompleteResult>(
          displayStringForOption: (result) => result.toString(),
          onSelected: onSelected,
          options: options,
          poweredByGoogleLogo: widget.poweredByGoogleLogo,
        );
      },
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') {
          return const Iterable<_AutocompleteResult>.empty();
        }
        return _results;
      },
      onSelected: (_AutocompleteResult selection) {
        debugPrint('You just selected $selection');
      },
      fieldViewBuilder: _buildFieldView,
    );
  }

  Widget _buildFieldView(
      BuildContext context,
      TextEditingController textEditingController,
      FocusNode focusNode,
      VoidCallback onFieldSubmitted) {
    return TextField(
      focusNode: focusNode,
      controller: textEditingController,
      decoration: widget.textFieldConfiguration.decoration.copyWith(
        errorText: widget.textFieldConfiguration.decoration.errorText,
        suffixIcon: InkResponse(
          radius: 24,
          canRequestFocus: false,
          child: const Icon(Icons.place),
          onTap: () {},
        ),
      ),
      style: widget.textFieldConfiguration.style,
      textAlign: widget.textFieldConfiguration.textAlign,
      enabled: widget.textFieldConfiguration.enabled,
      keyboardType: widget.textFieldConfiguration.keyboardType,
      autofocus: widget.textFieldConfiguration.autofocus,
      inputFormatters: widget.textFieldConfiguration.inputFormatters,
      autocorrect: widget.textFieldConfiguration.autocorrect,
      maxLines: widget.textFieldConfiguration.maxLines,
      textAlignVertical: widget.textFieldConfiguration.textAlignVertical,
      minLines: widget.textFieldConfiguration.minLines,
      maxLength: widget.textFieldConfiguration.maxLength,
      maxLengthEnforcement: widget.textFieldConfiguration.maxLengthEnforcement,
      obscureText: widget.textFieldConfiguration.obscureText,
      onChanged: widget.textFieldConfiguration.onChanged,
      onSubmitted: (_) => onFieldSubmitted(),
      onEditingComplete: widget.textFieldConfiguration.onEditingComplete,
      onTap: widget.textFieldConfiguration.onTap,
      scrollPadding: widget.textFieldConfiguration.scrollPadding,
      textInputAction: widget.textFieldConfiguration.textInputAction,
      textCapitalization: widget.textFieldConfiguration.textCapitalization,
      keyboardAppearance: widget.textFieldConfiguration.keyboardAppearance,
      cursorWidth: widget.textFieldConfiguration.cursorWidth,
      cursorRadius: widget.textFieldConfiguration.cursorRadius,
      cursorColor: widget.textFieldConfiguration.cursorColor,
      textDirection: widget.textFieldConfiguration.textDirection,
      enableInteractiveSelection:
          widget.textFieldConfiguration.enableInteractiveSelection,
      readOnly: widget.readOnly,
    );
  }
}

class _AutocompleteResult {
  String value;

  _AutocompleteResult(this.value);

  @override
  String toString() => value;
}

// From autocomplete.dart so that we can include the required "Powered By Google" logo.
class _AutocompleteOptions<T extends Object> extends StatelessWidget {
  const _AutocompleteOptions({
    Key? key,
    required this.displayStringForOption,
    required this.onSelected,
    required this.options,
    required this.poweredByGoogleLogo,
  }) : super(key: key);

  final AutocompleteOptionToString<T> displayStringForOption;

  final AutocompleteOnSelected<T> onSelected;

  final Iterable<T> options;
  final double maxOptionsHeight = 200.0;
  final Widget poweredByGoogleLogo;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        elevation: 4.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxOptionsHeight),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final T option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Builder(builder: (BuildContext context) {
                      final bool highlight =
                          AutocompleteHighlightedOption.of(context) == index;
                      if (highlight) {
                        SchedulerBinding.instance
                            .addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        });
                      }
                      return Container(
                        color: highlight ? Theme.of(context).focusColor : null,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(displayStringForOption(option)),
                      );
                    }),
                  );
                },
              ),
            ),
            poweredByGoogleLogo,
          ],
        ),
      ),
    );
  }
}

/// Supply an instance of this class to the [VscAddressLookupField.textFieldConfiguration]
/// property to configure the displayed text field
class TextFieldConfiguration {
  /// The decoration to show around the text field.
  ///
  /// Same as [TextField.decoration](https://docs.flutter.io/flutter/material/TextField/decoration.html)
  final InputDecoration decoration;

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController](https://docs.flutter.io/flutter/widgets/TextEditingController-class.html).
  /// A typical use case for this field in the VscAddressLookupField widget is to set the
  /// text of the widget when a date is selected. For example:
  ///
  /// ```dart
  /// final _controller = TextEditingController();
  /// ...
  /// ...
  /// VscAddressLookupField(
  ///   controller: _controller,
  ///   ...
  ///   ...
  /// )
  /// ```
  final TextEditingController? controller;

  /// Controls whether this widget has keyboard focus.
  ///
  /// Same as [TextField.focusNode](https://docs.flutter.io/flutter/material/TextField/focusNode.html)
  final FocusNode? focusNode;

  /// The style to use for the text being edited.
  ///
  /// Same as [TextField.style](https://docs.flutter.io/flutter/material/TextField/style.html)
  final TextStyle? style;

  /// How the text being edited should be aligned horizontally.
  ///
  /// Same as [TextField.textAlign](https://docs.flutter.io/flutter/material/TextField/textAlign.html)
  final TextAlign textAlign;

  /// Same as [TextField.textDirection](https://docs.flutter.io/flutter/material/TextField/textDirection.html)
  ///
  /// Defaults to null
  final TextDirection? textDirection;

  /// Same as [TextField.textAlignVertical](https://api.flutter.dev/flutter/material/TextField/textAlignVertical.html)
  final TextAlignVertical? textAlignVertical;

  /// If false the textfield is "disabled": it ignores taps and its
  /// [decoration] is rendered in grey.
  ///
  /// Same as [TextField.enabled](https://docs.flutter.io/flutter/material/TextField/enabled.html)
  final bool enabled;

  /// The type of keyboard to use for editing the text.
  ///
  /// Same as [TextField.keyboardType](https://docs.flutter.io/flutter/material/TextField/keyboardType.html)
  final TextInputType keyboardType;

  /// Whether this text field should focus itself if nothing else is already
  /// focused.
  ///
  /// Same as [TextField.autofocus](https://docs.flutter.io/flutter/material/TextField/autofocus.html)
  final bool autofocus;

  /// Optional input validation and formatting overrides.
  ///
  /// Same as [TextField.inputFormatters](https://docs.flutter.io/flutter/material/TextField/inputFormatters.html)
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to enable autocorrection.
  ///
  /// Same as [TextField.autocorrect](https://docs.flutter.io/flutter/material/TextField/autocorrect.html)
  final bool autocorrect;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// Same as [TextField.maxLines](https://docs.flutter.io/flutter/material/TextField/maxLines.html)
  final int? maxLines;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  ///
  /// Same as [TextField.minLines](https://docs.flutter.io/flutter/material/TextField/minLines.html)
  final int? minLines;

  /// The maximum number of characters (Unicode scalar values) to allow in the
  /// text field.
  ///
  /// Same as [TextField.maxLength](https://docs.flutter.io/flutter/material/TextField/maxLength.html)
  final int? maxLength;

  /// If true, prevents the field from allowing more than [maxLength]
  /// characters.
  ///
  /// Same as [TextField.maxLengthEnforcement](https://api.flutter.dev/flutter/material/TextField/maxLengthEnforcement.html)
  final MaxLengthEnforcement? maxLengthEnforcement;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// Same as [TextField.obscureText](https://docs.flutter.io/flutter/material/TextField/obscureText.html)
  final bool obscureText;

  /// Called when the text being edited changes.
  ///
  /// Same as [TextField.onChanged](https://docs.flutter.io/flutter/material/TextField/onChanged.html)
  final ValueChanged<String>? onChanged;

  /// Called when the user indicates that they are done editing the text in the
  /// field.
  ///
  /// Same as [TextField.onSubmitted](https://docs.flutter.io/flutter/material/TextField/onSubmitted.html)
  final ValueChanged<String>? onSubmitted;

  /// The color to use when painting the cursor.
  ///
  /// Same as [TextField.cursorColor](https://docs.flutter.io/flutter/material/TextField/cursorColor.html)
  final Color? cursorColor;

  /// How rounded the corners of the cursor should be. By default, the cursor has a null Radius
  ///
  /// Same as [TextField.cursorRadius](https://docs.flutter.io/flutter/material/TextField/cursorRadius.html)
  final Radius? cursorRadius;

  /// How thick the cursor will be.
  ///
  /// Same as [TextField.cursorWidth](https://docs.flutter.io/flutter/material/TextField/cursorWidth.html)
  final double cursorWidth;

  /// The appearance of the keyboard.
  ///
  /// Same as [TextField.keyboardAppearance](https://docs.flutter.io/flutter/material/TextField/keyboardAppearance.html)
  final Brightness? keyboardAppearance;

  /// Called when the user submits editable content (e.g., user presses the "done" button on the keyboard).
  ///
  /// Same as [TextField.onEditingComplete](https://docs.flutter.io/flutter/material/TextField/onEditingComplete.html)
  final VoidCallback? onEditingComplete;

  /// Called for each distinct tap except for every second tap of a double tap.
  ///
  /// Same as [TextField.onTap](https://docs.flutter.io/flutter/material/TextField/onTap.html)
  final GestureTapCallback? onTap;

  /// Configures padding to edges surrounding a Scrollable when the Textfield scrolls into view.
  ///
  /// Same as [TextField.scrollPadding](https://docs.flutter.io/flutter/material/TextField/scrollPadding.html)
  final EdgeInsets scrollPadding;

  /// Configures how the platform keyboard will select an uppercase or lowercase keyboard.
  ///
  /// Same as [TextField.TextCapitalization](https://docs.flutter.io/flutter/material/TextField/textCapitalization.html)
  final TextCapitalization textCapitalization;

  /// The type of action button to use for the keyboard.
  ///
  /// Same as [TextField.textInputAction](https://docs.flutter.io/flutter/material/TextField/textInputAction.html)
  final TextInputAction? textInputAction;

  final bool enableInteractiveSelection;

  /// Creates a TextFieldConfiguration
  const TextFieldConfiguration({
    this.decoration = const InputDecoration(),
    this.style,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.maxLengthEnforcement,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textAlignVertical,
    this.autocorrect = true,
    this.inputFormatters,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.focusNode,
    this.cursorColor,
    this.cursorRadius,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.cursorWidth = 2.0,
    this.keyboardAppearance,
    this.onEditingComplete,
    this.onTap,
    this.textDirection,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.enableInteractiveSelection = true,
  });

  /// Copies the [TextFieldConfiguration] and only changes the specified
  /// properties
  TextFieldConfiguration copyWith(
      {InputDecoration? decoration,
      TextStyle? style,
      TextEditingController? controller,
      ValueChanged<String>? onChanged,
      ValueChanged<String>? onSubmitted,
      bool? obscureText,
      MaxLengthEnforcement? maxLengthEnforcement,
      int? maxLength,
      int? maxLines,
      int? minLines,
      bool? autocorrect,
      List<TextInputFormatter>? inputFormatters,
      bool? autofocus,
      TextInputType? keyboardType,
      bool? enabled,
      TextAlign? textAlign,
      FocusNode? focusNode,
      Color? cursorColor,
      TextAlignVertical? textAlignVertical,
      Radius? cursorRadius,
      double? cursorWidth,
      Brightness? keyboardAppearance,
      VoidCallback? onEditingComplete,
      GestureTapCallback? onTap,
      EdgeInsets? scrollPadding,
      TextCapitalization? textCapitalization,
      TextDirection? textDirection,
      TextInputAction? textInputAction,
      bool? enableInteractiveSelection}) {
    return TextFieldConfiguration(
      decoration: decoration ?? this.decoration,
      style: style ?? this.style,
      controller: controller ?? this.controller,
      onChanged: onChanged ?? this.onChanged,
      onSubmitted: onSubmitted ?? this.onSubmitted,
      obscureText: obscureText ?? this.obscureText,
      maxLengthEnforcement: maxLengthEnforcement ?? this.maxLengthEnforcement,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      autocorrect: autocorrect ?? this.autocorrect,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      autofocus: autofocus ?? this.autofocus,
      keyboardType: keyboardType ?? this.keyboardType,
      enabled: enabled ?? this.enabled,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      focusNode: focusNode ?? this.focusNode,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorRadius: cursorRadius ?? this.cursorRadius,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      keyboardAppearance: keyboardAppearance ?? this.keyboardAppearance,
      onEditingComplete: onEditingComplete ?? this.onEditingComplete,
      onTap: onTap ?? this.onTap,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textInputAction: textInputAction ?? this.textInputAction,
      textDirection: textDirection ?? this.textDirection,
      enableInteractiveSelection:
          enableInteractiveSelection ?? this.enableInteractiveSelection,
    );
  }
}