import 'package:Sahemat/helpers/dynamic_link_service.dart';
import 'package:Sahemat/models/communityinfomodel.dart';
import 'package:Sahemat/models/link_to.dart';
import 'package:Sahemat/pages/signup.dart';
import 'package:Sahemat/variables.dart';
import 'package:Sahemat/widgets/button_simple.dart';
import 'package:Sahemat/widgets/featuredcommunity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Sahemat/pages/signin.dart';
import 'package:Sahemat/pages/home.dart';
import 'package:flutter/services.dart';

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool isSigned = false;
  String? useruid;
  bool dataisthere = false;
  bool prelinkcheck = false;

  @override
  initState() {
    super.initState();
    DynamicLinkService.initPreDynamicLink().then((_) {
      prelinkcheck = true;
    });
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (!mounted) return;
      if (user != null) {
        useruid = user.uid;
        setState(() {
          isSigned = true;
        });
      } else {
        setState(() {
          isSigned = false;
        });
      }
    });
    if (isSigned == false) {
      initDynamicLink();
    }
    if (!mounted) return;
    setState(() {
      dataisthere = true;
    });
  }

  Future<void> initDynamicLink() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      final Uri deepLink = dynamicLink.link;
      var isStory = deepLink.pathSegments.contains('linkToV1');
      if (isStory) {
        String docName = deepLink.queryParameters['docName'] ?? '';
        String linkType = deepLink.queryParameters['type'] ?? '';

        if (docName != '' && linkType != '') {
          try {
            preLinkedPage = LinkTo(docName: docName, type: linkType);
          } catch (e) {
            print("Error is ${e.toString()}");
          }
        }
      } else {
        //error
      }
    }).onError((error) {
      print("some error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return (dataisthere == false)
        ? const Scaffold(
            body: Center(
              child: CupertinoActivityIndicator(
                color: kDarkPrimaryColor,
              ),
            ),
          )
        : Scaffold(
            body: isSigned == false
                ? Welcome()
                : HomePage(
                    useruid: useruid!,
                  ));
  }
}

class Welcome extends StatefulWidget {
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  void initState() {
    super.initState();
    communities = [community1, community2, community3, community4];
    setState(() {
      allset = true;
    });
  }

  bool allset = false;
  int _currentPage = 0;
  final int _totalPages = 4;
  final community3 = CommunityInfoModel(
    communityName: 'Aam Aadmi Party',
    communityPic: 'assets/images/aadmi.png',
    communityBackgroundPic: 'assets/images/kejriwal.jpg',
    communityDescription: 'Community for Working of Aam Aadmi Party',
    communityMemberCount: 0,
  );

  final community2 = CommunityInfoModel(
      communityName: 'Indian National Congress',
      communityPic: 'assets/images/congress.png',
      communityBackgroundPic: 'assets/images/rahul.jpg',
      communityDescription: 'Browse through various discussion of Congress !!',
      communityMemberCount: 0);

  final community1 = CommunityInfoModel(
    communityName: 'Bharatiya Janata Party',
    communityPic: 'assets/images/bjp.png',
    communityBackgroundPic: 'assets/images/modi.jpg',
    communityDescription:
        'Community dedicated to discussing new Political events.',
    communityMemberCount: 0,
  );

  final community4 = CommunityInfoModel(
    communityName: 'All India Trinamool Congress',
    communityPic: 'assets/images/trinamool.png',
    communityBackgroundPic: 'assets/images/mamta.jpg',
    communityDescription:
        'Community dedicated for discussing AITC Events',
    communityMemberCount: 0,
  );

  // final community5 = CommunityInfoModel(
  //   communityName: 'gaming',
  //   communityPic: 'assets/images/cgaming_main.jpg',
  //   communityBackgroundPic: 'assets/images/gaming_background.jpg',
  //   communityDescription:
  //       "News, reviews of the latest video games and consoles.",
  //   communityMemberCount: 0,
  // );

  late List<CommunityInfoModel> communities;

  List<Widget> buildPageIndicator() {
    List<Widget> list = [];
    for (var i = 0; i < _totalPages; i++) {
      list.add(buildIndicator(i == _currentPage));
    }
    return list;
  }

  Widget buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color: isActive ? kHeadlineColorDark : kIconSecondaryColorDark,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget featuredCommunities() {
    return Container(
      height: 200,
      child: PageView(
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: [
          for (CommunityInfoModel eachcommunity in communities)
            FeaturedCommunity(
              whetherassetimages: true,
              onTapped: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                  "You must sign in to view communities.",
                )));
              },
              width: MediaQuery.of(context).size.width,
              backgroundheight: 100,
              foregroundposition: 70,
              foregroundradius: 30,
              postpictextpadding: 18.0,
              showmembercount: false,
              namesize: 15.0,
              descriptionsize: 12.0,
              descmaxlines: 2,
              community: CommunityInfoModel(
                communityName: eachcommunity.communityName,
                communityDescription: eachcommunity.communityDescription,
                communityMemberCount: eachcommunity.communityMemberCount,
                communityPic: eachcommunity.communityPic,
                communityBackgroundPic: eachcommunity.communityBackgroundPic,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: kBackgroundColorDark,
      ),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: kBackgroundColorDark,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: kBackgroundColorDark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
        //backgroundColor: kBackgroundColorDark,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: (allset == false)
                ? const Center(
                    child: CupertinoActivityIndicator(
                      color: kPrimaryColor,
                    ),
                  )
                : SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          SizedBox(
                            height: 90,
                            child: Image.asset(
                              "assets/icons/main_logo.png",
                              //color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Join Sahemat.",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: const Color(0xFFfffffe),
                                  fontSize: 27,
                                  fontWeight: FontWeight.w700,
                                  //wordSpacing: 0.5,
                                ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            "Stream discussions, share content & join communities.",
                            style:
                                Theme.of(context).textTheme.caption!.copyWith(
                                      color: const Color(0xFF94a1b2),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          Text(
                            "Featured communities",
                            style:
                                Theme.of(context).textTheme.subtitle2!.copyWith(
                                      color: const Color(0xFFfffffe),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20.0,
                                    ),
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          featuredCommunities(),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: buildPageIndicator(),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          ButtonSimple(
                            text: "Sign in",
                            onPress: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()));
                            },
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ButtonSimple(
                            color: kPrimaryColor,
                            textColor: kHeadlineColorDark,
                            text: "Create account",
                            onPress: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp())),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
