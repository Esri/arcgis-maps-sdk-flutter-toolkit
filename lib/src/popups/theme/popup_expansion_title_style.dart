part of '../../../arcgis_maps_toolkit.dart';

class PopupExpansionTileStyle {
  const PopupExpansionTileStyle({
    this.leading,
    this.trailing,
    this.tilePadding,
    this.textColor,
    this.showTrailingIcon = true,
    this.initiallyExpanded = false,
    this.expandedCrossAxisAlignment,
    this.expandedAlignment,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
    this.collapsedTextColor,
    this.iconColor,
    this.collapsedIconColor,
    this.shape,
    this.collapsedShape,
    this.clipBehavior,
    this.dense,
    this.minTileHeight,
    this.enabled = true,
    this.expansionAnimationStyle,
  });
  final Widget? leading;
  final Widget? trailing;
  final bool showTrailingIcon;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? tilePadding;
  final CrossAxisAlignment? expandedCrossAxisAlignment;
  final Alignment? expandedAlignment;
  final EdgeInsetsGeometry? childrenPadding;
  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;
  final Color? textColor;
  final Color? collapsedTextColor;
  final Color? iconColor;
  final Color? collapsedIconColor;
  final ShapeBorder? shape;
  final ShapeBorder? collapsedShape;
  final Clip? clipBehavior;
  final double? minTileHeight;
  final bool enabled;
  final bool? dense;
  final AnimationStyle? expansionAnimationStyle;
}

class PopupElementStyle {
  const PopupElementStyle({
    this.shape,
    //this.color,
    this.elevation,
    this.margin,
    this.chartColor,
    this.chartForegroundColor,
    this.clipBehavior,
    this.tile,
  });

  // Card styling
  final ShapeBorder? shape;
  //final Color? color;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final Clip? clipBehavior;
  final Color? chartColor;
  final Color? chartForegroundColor;

  // ExpansionTile styling
  final PopupExpansionTileStyle? tile;
}
