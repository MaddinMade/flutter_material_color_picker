import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/src/circle_color.dart';
import 'package:flutter_material_color_picker/src/colors.dart';

class MaterialColorPicker extends StatefulWidget {
  final Color? selectedColor;
  final ValueChanged<Color>? onColorChange;
  final ValueChanged<ColorSwatch?>? onMainColorChange;
  final List<ColorSwatch>? colors;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool allowShades;
  final bool onlyShadeSelection;
  final double circleSize;
  final double spacing;
  final IconData iconSelected;
  final VoidCallback? onBack;
  final double? elevation;
  final Duration animationDuration;
  final Widget backIcon;

  const MaterialColorPicker({
    Key? key,
    this.selectedColor,
    this.onColorChange,
    this.onMainColorChange,
    this.colors,
    this.shrinkWrap = true,
    this.physics,
    this.allowShades = true,
    this.onlyShadeSelection = false,
    this.iconSelected = Icons.check,
    this.circleSize = 45.0,
    this.spacing = 9.0,
    this.onBack,
    this.elevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.backIcon = const Icon(Icons.arrow_back),
  }) : super(key: key);

  @override
  _MaterialColorPickerState createState() => _MaterialColorPickerState();
}

class _MaterialColorPickerState extends State<MaterialColorPicker> {
  final _defaultValue = materialColors[0];

  List<ColorSwatch> _colors = materialColors;

  late ColorSwatch? _mainColor;
  late Color? _shadeColor;
  bool _isMainSelection = true;

  @override
  void initState() {
    super.initState();
    _initSelectedValue();
  }

  @protected
  void didUpdateWidget(covariant MaterialColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) _initSelectedValue();
  }

  void _initSelectedValue() {
    _colors = widget.colors ?? materialColors;

    Color shadeColor = widget.selectedColor ?? _defaultValue;
    ColorSwatch? mainColor = _findMainColor(shadeColor);

    setState(() {
      _mainColor = mainColor;
      _shadeColor = shadeColor;
      _isMainSelection = true;
    });
  }

  ColorSwatch? _findMainColor(Color? shadeColor) {
    if (shadeColor == null) return null;
    for (final ColorSwatch mainColor in _colors)
      if (_isShadeOfMain(mainColor, shadeColor)) return mainColor;

    return (shadeColor is ColorSwatch && _colors.contains(shadeColor))
        ? shadeColor
        : null;
  }

  bool _isShadeOfMain(ColorSwatch mainColor, Color shadeColor) {
    for (final shade in _getMaterialColorShades(mainColor)) {
      if (shade == shadeColor) return true;
    }
    return false;
  }

  void _onMainColorSelected(ColorSwatch color) {
    setState(() {
      _mainColor = color;
      //_shadeColor = shadeColor;
      _isMainSelection = false;
    });
    widget.onMainColorChange?.call(color);
    if (widget.onlyShadeSelection && !_isMainSelection) {
      return;
    }
    //if (widget.allowShades) {widget.onColorChange?.call(shadeColor);}
  }

  void _onShadeColorSelected(Color color) {
    setState(() => _shadeColor = color);
    widget.onColorChange?.call(color);
  }

  void _onBack() {
    setState(() {
      _mainColor = _findMainColor(_shadeColor);
      _isMainSelection = true;
    });
    widget.onBack?.call();
  }

  List<Widget> _buildListMainColor(List<ColorSwatch> colors) {
    return [
      for (final color in colors)
        CircleColor(
          color: color,
          circleSize: widget.circleSize,
          onColorChoose: (_) => _onMainColorSelected(color),
          isSelected: _mainColor == color,
          iconSelected: widget.iconSelected,
          elevation: widget.elevation,
        )
    ];
  }

  List<Color> _getMaterialColorShades(ColorSwatch color) {
    return <Color>[
      if (color[50] != null) color[50]!,
      if (color[100] != null) color[100]!,
      if (color[200] != null) color[200]!,
      if (color[300] != null) color[300]!,
      if (color[400] != null) color[400]!,
      if (color[500] != null) color[500]!,
      if (color[600] != null) color[600]!,
      if (color[700] != null) color[700]!,
      if (color[800] != null) color[800]!,
      if (color[900] != null) color[900]!,
    ];
  }

  List<Widget> _buildListShadesColor(ColorSwatch color) {
    return [
      IconButton(
        icon: widget.backIcon,
        onPressed: _onBack,
        padding: const EdgeInsets.only(right: 2.0),
      ),
      for (final color in _getMaterialColorShades(color))
        CircleColor(
          color: color,
          circleSize: widget.circleSize,
          onColorChoose: _onShadeColorSelected,
          isSelected: _shadeColor == color,
          iconSelected: widget.iconSelected,
          elevation: widget.elevation,
          animationDuration: widget.animationDuration,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final listChildren = _isMainSelection || !widget.allowShades
        ? _buildListMainColor(_colors)
        : _buildListShadesColor(_mainColor!);

    // Size of dialog
    final double width = MediaQuery.of(context).size.width * 0.8;
    // Number of circle per line, depend on width and circleSize
    final int nbrCircleLine = width ~/ (widget.circleSize + widget.spacing);

    return Container(
      width: width,
      child: GridView.count(
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: widget.spacing,
        mainAxisSpacing: widget.spacing,
        crossAxisCount: nbrCircleLine,
        children: listChildren,
      ),
    );
  }
}
