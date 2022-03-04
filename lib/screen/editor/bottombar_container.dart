import 'package:flutter/material.dart';

class BottomBarContainer extends StatelessWidget {
  final Color colors;
  final Function onTap;
  final String title;
  final IconData icons;

  const BottomBarContainer(
      {Key key, this.onTap, this.title, this.icons, this.colors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      width: MediaQuery.of(context).size.width / 5,
      child: Material(
        color: colors,
        child: InkWell(
          onTap: onTap as void Function(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icons,
                  color: Colors.white,
                ),
                const SizedBox(height: 4.0),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
