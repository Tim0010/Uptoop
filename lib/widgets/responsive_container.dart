import 'package:flutter/material.dart';
import 'package:uptop_careers/utils/responsive.dart';

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding =
        padding ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsivePadding(context),
        );

    final responsiveMargin = margin ?? EdgeInsets.zero;
    final responsiveMaxWidth =
        maxWidth ?? ResponsiveHelper.getResponsiveWidth(context);

    return Container(
      margin: responsiveMargin,
      constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
      child: Padding(padding: responsivePadding, child: child),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getResponsiveGridColumns(context);

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.asMap().entries.map((entry) {
        final width =
            (MediaQuery.of(context).size.width -
                (spacing * (columns - 1)) -
                (ResponsiveHelper.getResponsivePadding(context) * 2)) /
            columns;
        return SizedBox(width: width, child: entry.value);
      }).toList(),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final TextAlign? textAlign;

  const ResponsiveText(
    this.text, {
    super.key,
    this.baseStyle,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: mobileSize ?? 14,
      tablet: tabletSize,
      desktop: desktopSize,
    );

    return Text(
      text,
      style: (baseStyle ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
    );
  }
}
