import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Text('Cinemapedia',style: titleStyle,),
              Spacer(),
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.search_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}