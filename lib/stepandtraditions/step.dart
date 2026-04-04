import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/stepandtraditions/traditions.dart';
import 'package:aahelp/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StepAndTraditions extends StatelessWidget {
  const StepAndTraditions({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Тексты, к которым удобно возвращаться каждый день',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Короткая навигация по 12 шагам и 12 традициям, с раскрытием подробных формулировок там, где это полезно.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: '12 шагов'),
                    Tab(text: '12 традиций'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: TabBarView(
              children: [
                Step12(),
                Traditions12(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Step12 extends StatelessWidget {
  const Step12({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return AnimatedStepCard(
          step: steps[index],
          index: index,
        );
      },
    );
  }
}

class AnimatedStepCard extends StatefulWidget {
  const AnimatedStepCard({
    super.key,
    required this.step,
    required this.index,
  });

  final Map<String, String> step;
  final int index;

  @override
  State<AnimatedStepCard> createState() => _AnimatedStepCardState();
}

class _AnimatedStepCardState extends State<AnimatedStepCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 440 + (widget.index * 45)),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = context.appPalette;

    return SlideTransition(
      position: _offsetAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: AppPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: palette.accentSoft,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: palette.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.step['title']!,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.step['text']!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final List<Map<String, String>> steps = [
  {
    'title': 'Шаг 1',
    'text':
        'Мы признали свое бессилие перед алкоголем, признали, что потеряли контроль над собой.',
  },
  {
    'title': 'Шаг 2',
    'text':
        'Пришли к убеждению, что только Сила более могущественная, чем мы, может вернуть нам здравомыслие.',
  },
  {
    'title': 'Шаг 3',
    'text':
        'Приняли решение препоручить нашу волю и нашу жизнь Богу, как мы Его понимали.',
  },
  {
    'title': 'Шаг 4',
    'text':
        'Глубоко и бесстрашно оценили себя и свою жизнь с нравственной точки зрения.',
  },
  {
    'title': 'Шаг 5',
    'text':
        'Признали перед Богом, собой и каким-либо другим человеком истинную природу наших заблуждений.',
  },
  {
    'title': 'Шаг 6',
    'text':
        'Полностью подготовили себя к тому, чтобы Бог избавил нас от наших недостатков.',
  },
  {
    'title': 'Шаг 7',
    'text': 'Смиренно просили Его исправить наши изъяны.',
  },
  {
    'title': 'Шаг 8',
    'text':
        'Составили список всех тех людей, кому мы причинили зло, и преисполнились желанием загладить свою вину перед ними.',
  },
  {
    'title': 'Шаг 9',
    'text':
        'Лично возмещали причиненный этим людям ущерб, где только возможно, кроме тех случаев, когда это могло повредить им или кому-либо другому.',
  },
  {
    'title': 'Шаг 10',
    'text':
        'Продолжали самоанализ и, когда допускали ошибки, сразу признавали это.',
  },
  {
    'title': 'Шаг 11',
    'text':
        'Стремились путем молитвы и размышления углубить соприкосновение с Богом, как мы понимали Его, молясь лишь о знании Его воли, которую нам надлежит исполнить, и о даровании силы для этого.',
  },
  {
    'title': 'Шаг 12',
    'text':
        'Достигнув духовного пробуждения, к которому привели эти шаги, мы старались донести смысл наших идей до других алкоголиков и применять эти принципы во всех наших делах.',
  },
];
