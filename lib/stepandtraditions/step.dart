import 'package:aahelp/helper/stylemenu.dart';
import 'package:aahelp/stepandtraditions/traditions.dart';
import 'package:flutter/material.dart';

class StepAndTraditions extends StatefulWidget {
  final String title;

  const StepAndTraditions({super.key, required this.title});

  @override
  State<StepAndTraditions> createState() => _StepAndTraditionsState();
}

class _StepAndTraditionsState extends State<StepAndTraditions>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> tabname = ['12 Шагов', '12 Традиций'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabname.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: BeautifulText(
          text: widget.title,
          color: Colors.brown,
          fontSize: 18,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: List.generate(
              _tabController.length, (index) => Tab(text: tabname[index])),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Step12(),
          Traditions12(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class Step12 extends StatelessWidget {
  const Step12({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
  final Map<String, String> step;
  final int index;

  const AnimatedStepCard({
    super.key,
    required this.step,
    required this.index,
  });

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
      duration: Duration(milliseconds: 500 + (widget.index * 100)),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
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
    return SlideTransition(
      position: _offsetAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: BeautifulText(
                          text: '${widget.index + 1}',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BeautifulText(
                        text: widget.step['title']!,
                        fontSize: 18,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                BeautifulText(
                  text: widget.step['text']!,
                  fontSize: 16,
                  textAlign: TextAlign.justify,
                  color: Colors.black,
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
