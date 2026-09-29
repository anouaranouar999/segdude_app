import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Lkout'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// timetable page
  ///
  /// In en, this message translates to:
  /// **'timetable'**
  String get timetable;

  /// timetable create page
  ///
  /// In en, this message translates to:
  /// **'Create timetable'**
  String get timetableCreate;

  /// timetable result page
  ///
  /// In en, this message translates to:
  /// **'timetable Result'**
  String get timetableResult;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be ≥ 1'**
  String get mustBePositive;

  /// No description provided for @idAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'ID already in use'**
  String get idAlreadyUsed;

  /// No description provided for @minTwoChars.
  ///
  /// In en, this message translates to:
  /// **'Min. 2 characters'**
  String get minTwoChars;

  /// No description provided for @invalidHoursFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: levelId:hours — e.g. 1:6,2:4'**
  String get invalidHoursFormat;

  /// No description provided for @levelsRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one level — e.g. 1,2'**
  String get levelsRequired;

  /// No description provided for @invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format — e.g. 1,2'**
  String get invalidFormat;

  /// No description provided for @slotRange.
  ///
  /// In en, this message translates to:
  /// **'Slot must be between 1 and 24'**
  String get slotRange;

  /// No description provided for @slotAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'Slot already defined as a break'**
  String get slotAlreadyUsed;

  /// No description provided for @dayRange.
  ///
  /// In en, this message translates to:
  /// **'Day must be between 1 and 7'**
  String get dayRange;

  /// No description provided for @minTwo.
  ///
  /// In en, this message translates to:
  /// **'Must be ≥ 2'**
  String get minTwo;

  /// No description provided for @selectASubject.
  ///
  /// In en, this message translates to:
  /// **'Select a subject'**
  String get selectASubject;

  /// No description provided for @searchTeacherHint.
  ///
  /// In en, this message translates to:
  /// **'Search teacher...'**
  String get searchTeacherHint;

  /// No description provided for @noTeachersForSubject.
  ///
  /// In en, this message translates to:
  /// **'No teachers for this subject'**
  String get noTeachersForSubject;

  /// No description provided for @addRooms.
  ///
  /// In en, this message translates to:
  /// **'Add Rooms'**
  String get addRooms;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get addSubject;

  /// No description provided for @editTeacher.
  ///
  /// In en, this message translates to:
  /// **'Edit Teacher'**
  String get editTeacher;

  /// No description provided for @teacherUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String teacherUpdatedSuccessfully(String name);

  /// No description provided for @noTeacherScheduleAvailable.
  ///
  /// In en, this message translates to:
  /// **'No teacher schedule available'**
  String get noTeacherScheduleAvailable;

  /// No description provided for @teacherNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Teacher {id}'**
  String teacherNumberFallback(String id);

  /// No description provided for @dayNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Day {id}'**
  String dayNumberFallback(String id);

  /// No description provided for @subjectNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Subject {id}'**
  String subjectNumberFallback(String id);

  /// No description provided for @classNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Class {id}'**
  String classNumberFallback(String id);

  /// No description provided for @roomNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Room {id}'**
  String roomNumberFallback(String id);

  /// No description provided for @editSubject.
  ///
  /// In en, this message translates to:
  /// **'Edit Subject'**
  String get editSubject;

  /// No description provided for @editRoom.
  ///
  /// In en, this message translates to:
  /// **'Edit Room'**
  String get editRoom;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher'**
  String get addTeacher;

  /// No description provided for @addABreakHour.
  ///
  /// In en, this message translates to:
  /// **'Add a break hour'**
  String get addABreakHour;

  /// No description provided for @addEdit.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit'**
  String get addEdit;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared!'**
  String get allDataCleared;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome'**
  String get awesome;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @chooseLevel.
  ///
  /// In en, this message translates to:
  /// **'Choose level...'**
  String get chooseLevel;

  /// No description provided for @clearOverrides.
  ///
  /// In en, this message translates to:
  /// **'Clear Overrides'**
  String get clearOverrides;

  /// No description provided for @confirmPay.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get confirmPay;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get confirmPayment;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @createSchedule.
  ///
  /// In en, this message translates to:
  /// **'Create Schedule'**
  String get createSchedule;

  /// No description provided for @createSubject.
  ///
  /// In en, this message translates to:
  /// **'Create Subject'**
  String get createSubject;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get enterPhoneNumber;

  /// No description provided for @errorMsg.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorMsg;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @insufficientTeachers.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Teachers'**
  String get insufficientTeachers;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @manualOverridesPlanner.
  ///
  /// In en, this message translates to:
  /// **'Manual Overrides Planner'**
  String get manualOverridesPlanner;

  /// No description provided for @minutesMustBeBetween1And59.
  ///
  /// In en, this message translates to:
  /// **'Minutes must be between 1 and 59!'**
  String get minutesMustBeBetween1And59;

  /// No description provided for @noRoomsConfiguredYet.
  ///
  /// In en, this message translates to:
  /// **'No rooms configured yet.'**
  String get noRoomsConfiguredYet;

  /// No description provided for @noSubjectsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No subjects added yet.'**
  String get noSubjectsAddedYet;

  /// No description provided for @noTeachersAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'No teachers assigned yet. Use Menu Above to Disable including teachers'**
  String get noTeachersAssignedYet;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirmQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get confirmQuestion;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @pinSlot.
  ///
  /// In en, this message translates to:
  /// **'Pin Slot'**
  String get pinSlot;

  /// No description provided for @pleaseAddRooms.
  ///
  /// In en, this message translates to:
  /// **'Please add rooms'**
  String get pleaseAddRooms;

  /// No description provided for @pleaseAddSubjects.
  ///
  /// In en, this message translates to:
  /// **'Please add subjects'**
  String get pleaseAddSubjects;

  /// No description provided for @pleaseAddTeachers.
  ///
  /// In en, this message translates to:
  /// **'Please add teachers OR disable including teachers in payload'**
  String get pleaseAddTeachers;

  /// No description provided for @includeTeachersInPayload.
  ///
  /// In en, this message translates to:
  /// **'Include real teacher list'**
  String get includeTeachersInPayload;

  /// No description provided for @includeTeachersInPayloadHint.
  ///
  /// In en, this message translates to:
  /// **'When disabled, the generator sends placeholder teachers to the backend while still allowing schedule creation.'**
  String get includeTeachersInPayloadHint;

  /// No description provided for @pleaseSelectAClassFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a class first!'**
  String get pleaseSelectAClassFirst;

  /// No description provided for @pleaseSelectAtLeastOneWorkingD.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one working day'**
  String get pleaseSelectAtLeastOneWorkingD;

  /// No description provided for @scheduleResult.
  ///
  /// In en, this message translates to:
  /// **'Schedule Result'**
  String get scheduleResult;

  /// No description provided for @scheduleSkeleton.
  ///
  /// In en, this message translates to:
  /// **'Schedule Skeleton'**
  String get scheduleSkeleton;

  /// No description provided for @scheduleDataNotFound.
  ///
  /// In en, this message translates to:
  /// **'Schedule data not found.'**
  String get scheduleDataNotFound;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @timingConstraints.
  ///
  /// In en, this message translates to:
  /// **'Timing Constraints'**
  String get timingConstraints;

  /// No description provided for @tryAnyway.
  ///
  /// In en, this message translates to:
  /// **'Try Anyway'**
  String get tryAnyway;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @yourPremiumFeaturesHaveBeenUnl.
  ///
  /// In en, this message translates to:
  /// **'Your premium features have been unlocked.'**
  String get yourPremiumFeaturesHaveBeenUnl;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get confirmLogoutTitle;

  /// No description provided for @confirmLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogoutMessage;

  /// No description provided for @alreadyHave.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHave;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @institution.
  ///
  /// In en, this message translates to:
  /// **'Institution'**
  String get institution;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @emailNotConfirmedError.
  ///
  /// In en, this message translates to:
  /// **'Email not confirmed.'**
  String get emailNotConfirmedError;

  /// No description provided for @pleaseConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email'**
  String get pleaseConfirmEmail;

  /// No description provided for @emailWillBeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Email will be sent to : '**
  String get emailWillBeSentTo;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get errorPrefix;

  /// No description provided for @signInWelcome.
  ///
  /// In en, this message translates to:
  /// **'Sign In Welcome'**
  String get signInWelcome;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @shortPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get shortPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @pleaseSelectRole.
  ///
  /// In en, this message translates to:
  /// **'Please select a role'**
  String get pleaseSelectRole;

  /// No description provided for @welcomesegtotimetable.
  ///
  /// In en, this message translates to:
  /// **'Welcome to seg-timetable'**
  String get welcomesegtotimetable;

  /// No description provided for @noMorePlaceAnimation.
  ///
  /// In en, this message translates to:
  /// **'No More Place For Animation'**
  String get noMorePlaceAnimation;

  /// No description provided for @emptyFirstName.
  ///
  /// In en, this message translates to:
  /// **'emptyFirstName'**
  String get emptyFirstName;

  /// No description provided for @emptyLastName.
  ///
  /// In en, this message translates to:
  /// **'emptyLastName'**
  String get emptyLastName;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'fillAllFields'**
  String get fillAllFields;

  /// No description provided for @passwordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'passwordNotMatch'**
  String get passwordNotMatch;

  /// No description provided for @roleDirector.
  ///
  /// In en, this message translates to:
  /// **'Director'**
  String get roleDirector;

  /// No description provided for @roleSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get roleSupervisor;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'role'**
  String get roleLabel;

  /// No description provided for @signInLabel.
  ///
  /// In en, this message translates to:
  /// **'sign_in'**
  String get signInLabel;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @teachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachers;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @rooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get rooms;

  /// No description provided for @restricted.
  ///
  /// In en, this message translates to:
  /// **'restricted'**
  String get restricted;

  /// No description provided for @consecutive.
  ///
  /// In en, this message translates to:
  /// **'consecutive'**
  String get consecutive;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @weeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Weekly Hours'**
  String get weeklyHours;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// Compact label above the subject dropdown in the Teacher tab, explaining it filters the teacher list
  ///
  /// In en, this message translates to:
  /// **'Filter teachers by subject'**
  String get filterTeachersBySubject;

  /// Default option in the Teacher tab's subject filter dropdown, meaning no subject filter is applied
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get allSubjects;

  /// Hint text for the teacher search field in the Teacher tab
  ///
  /// In en, this message translates to:
  /// **'Search for a teacher'**
  String get searchForATeacher;

  /// Empty-state message shown in the Teacher tab's schedule area before a teacher is selected
  ///
  /// In en, this message translates to:
  /// **'Select a teacher to view their schedule.'**
  String get selectATeacherToViewSchedule;

  /// No description provided for @roomAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" added successfully'**
  String roomAddedSuccessfully(String name);

  /// No description provided for @roomRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" removed'**
  String roomRemoved(String name);

  /// No description provided for @roomUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" updated successfully'**
  String roomUpdatedSuccessfully(String name);

  /// No description provided for @teacherAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully'**
  String teacherAddedSuccessfully(String name);

  /// No description provided for @teacherRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} removed'**
  String teacherRemoved(String name);

  /// No description provided for @nLevelsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} level(s) selected'**
  String nLevelsSelected(int count);

  /// No description provided for @nSubjectsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} subject(s) selected'**
  String nSubjectsSelected(int count);

  /// No description provided for @capacityValue.
  ///
  /// In en, this message translates to:
  /// **'Capacity: {value}'**
  String capacityValue(int value);

  /// No description provided for @maxHoursPerWeekValue.
  ///
  /// In en, this message translates to:
  /// **'max {value}h/w'**
  String maxHoursPerWeekValue(int value);

  /// No description provided for @classesInLevel.
  ///
  /// In en, this message translates to:
  /// **'Classes in {level}'**
  String classesInLevel(String level);

  /// No description provided for @templatePlannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Template Planner: {className}'**
  String templatePlannerTitle(String className);

  /// No description provided for @pinLessonForClass.
  ///
  /// In en, this message translates to:
  /// **'Pin Lesson for {className}'**
  String pinLessonForClass(String className);

  /// No description provided for @dayAndSlot.
  ///
  /// In en, this message translates to:
  /// **'{day}, Slot {slot}'**
  String dayAndSlot(String day, int slot);

  /// No description provided for @slotNumber.
  ///
  /// In en, this message translates to:
  /// **'Slot {number}'**
  String slotNumber(int number);

  /// No description provided for @nPinned.
  ///
  /// In en, this message translates to:
  /// **'{count} pinned'**
  String nPinned(int count);

  /// No description provided for @sectionBasicInformation.
  ///
  /// In en, this message translates to:
  /// **'BASIC INFORMATION'**
  String get sectionBasicInformation;

  /// No description provided for @sectionRestrictionsOptional.
  ///
  /// In en, this message translates to:
  /// **'RESTRICTIONS  (OPTIONAL)'**
  String get sectionRestrictionsOptional;

  /// No description provided for @sectionConstraints.
  ///
  /// In en, this message translates to:
  /// **'CONSTRAINTS'**
  String get sectionConstraints;

  /// No description provided for @cardRoomName.
  ///
  /// In en, this message translates to:
  /// **'ROOM NAME'**
  String get cardRoomName;

  /// No description provided for @cardCapacityOptional.
  ///
  /// In en, this message translates to:
  /// **'CAPACITY  (OPTIONAL)'**
  String get cardCapacityOptional;

  /// No description provided for @cardAllowedLevels.
  ///
  /// In en, this message translates to:
  /// **'ALLOWED LEVELS'**
  String get cardAllowedLevels;

  /// No description provided for @cardAllowedSubjects.
  ///
  /// In en, this message translates to:
  /// **'ALLOWED SUBJECTS'**
  String get cardAllowedSubjects;

  /// No description provided for @cardUsedOnlyFor.
  ///
  /// In en, this message translates to:
  /// **'USED ONLY FOR'**
  String get cardUsedOnlyFor;

  /// No description provided for @cardTeacherName.
  ///
  /// In en, this message translates to:
  /// **'TEACHER NAME'**
  String get cardTeacherName;

  /// No description provided for @cardSubject.
  ///
  /// In en, this message translates to:
  /// **'SUBJECT'**
  String get cardSubject;

  /// No description provided for @cardQualifiedLevels.
  ///
  /// In en, this message translates to:
  /// **'QUALIFIED LEVELS'**
  String get cardQualifiedLevels;

  /// No description provided for @cardMaxHoursWeekOptional.
  ///
  /// In en, this message translates to:
  /// **'MAX HOURS / WEEK  (OPTIONAL)'**
  String get cardMaxHoursWeekOptional;

  /// No description provided for @cardConsecutiveHours.
  ///
  /// In en, this message translates to:
  /// **'CONSECUTIVE HOURS'**
  String get cardConsecutiveHours;

  /// No description provided for @tooltipRoomName.
  ///
  /// In en, this message translates to:
  /// **'A unique name that identifies this room. Can be a number, label, or description.'**
  String get tooltipRoomName;

  /// No description provided for @tooltipCapacity.
  ///
  /// In en, this message translates to:
  /// **'Maximum students this room can hold. Scheduler avoids overcrowding. Default is 40.'**
  String get tooltipCapacity;

  /// No description provided for @tooltipAllowedLevels.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to allow any level. Select specific levels to reserve this room for them.'**
  String get tooltipAllowedLevels;

  /// No description provided for @tooltipAllowedSubjects.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to allow any subject. Select subjects to restrict this room (e.g. a lab for Chemistry only).'**
  String get tooltipAllowedSubjects;

  /// No description provided for @tooltipUsedOnlyFor.
  ///
  /// In en, this message translates to:
  /// **'Select a subject to make it mandatory for this room (e.g. a lab for Chemistry only).'**
  String get tooltipUsedOnlyFor;

  /// No description provided for @tooltipTeacherName.
  ///
  /// In en, this message translates to:
  /// **'Must be unique. Used to identify this teacher across the schedule.'**
  String get tooltipTeacherName;

  /// No description provided for @tooltipTeacherSubject.
  ///
  /// In en, this message translates to:
  /// **'Each teacher is assigned to one subject. The scheduler matches teachers to classes using this.'**
  String get tooltipTeacherSubject;

  /// No description provided for @tooltipQualifiedLevels.
  ///
  /// In en, this message translates to:
  /// **'School grades or year groups this teacher is allowed to teach. Select all that apply.'**
  String get tooltipQualifiedLevels;

  /// No description provided for @tooltipMaxHoursWeek.
  ///
  /// In en, this message translates to:
  /// **'Prevents assigning more than this number of hours to this teacher in a single week.'**
  String get tooltipMaxHoursWeek;

  /// No description provided for @tooltipConsecutiveHours.
  ///
  /// In en, this message translates to:
  /// **'When enabled, the scheduler tries to group this teacher\'s sessions into a continuous block.'**
  String get tooltipConsecutiveHours;

  /// No description provided for @hintEnterRoomName.
  ///
  /// In en, this message translates to:
  /// **'Enter room name'**
  String get hintEnterRoomName;

  /// No description provided for @hintCapacity.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30'**
  String get hintCapacity;

  /// No description provided for @hintEnterTeacherName.
  ///
  /// In en, this message translates to:
  /// **'Enter teacher name'**
  String get hintEnterTeacherName;

  /// No description provided for @hintSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select a subject'**
  String get hintSelectSubject;

  /// No description provided for @hintMaxHours.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20'**
  String get hintMaxHours;

  /// No description provided for @capacityDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum number of students. Leave empty to use the default (40).'**
  String get capacityDescription;

  /// No description provided for @allowedLevelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Only Selected Levels Allowed. Leave empty to allow any level.'**
  String get allowedLevelsDescription;

  /// No description provided for @allowedSubjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to allow all subjects. Select subjects to restrict this room.'**
  String get allowedSubjectsDescription;

  /// No description provided for @usedOnlyForDescription.
  ///
  /// In en, this message translates to:
  /// **'Subject forced to use this room only (e.g. a lab for Chemistry only).'**
  String get usedOnlyForDescription;

  /// No description provided for @qualifiedLevelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Select every level this teacher is qualified to teach.'**
  String get qualifiedLevelsDescription;

  /// No description provided for @maxHoursWeekDescription.
  ///
  /// In en, this message translates to:
  /// **'Leave empty for no weekly limit. Useful for part-time teachers.'**
  String get maxHoursWeekDescription;

  /// No description provided for @requireConsecutiveHours.
  ///
  /// In en, this message translates to:
  /// **'Require consecutive hours'**
  String get requireConsecutiveHours;

  /// No description provided for @consecutiveHoursDescription.
  ///
  /// In en, this message translates to:
  /// **'Teacher\'s classes will be scheduled back-to-back.'**
  String get consecutiveHoursDescription;

  /// No description provided for @validationRoomNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Room name is required'**
  String get validationRoomNameRequired;

  /// No description provided for @validationNameMinTwoChars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get validationNameMinTwoChars;

  /// No description provided for @validationRoomNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A room with this name already exists'**
  String get validationRoomNameAlreadyExists;

  /// No description provided for @validationMustBeNumberGteOne.
  ///
  /// In en, this message translates to:
  /// **'Must be a number ≥ 1'**
  String get validationMustBeNumberGteOne;

  /// No description provided for @validationTeacherNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Teacher name is required'**
  String get validationTeacherNameRequired;

  /// No description provided for @validationTeacherNameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A teacher with this name already exists'**
  String get validationTeacherNameAlreadyExists;

  /// No description provided for @validationSelectSubjectOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject or create one'**
  String get validationSelectSubjectOrCreate;

  /// No description provided for @validationSelectAtLeastOneLevel.
  ///
  /// In en, this message translates to:
  /// **'Select at least one level'**
  String get validationSelectAtLeastOneLevel;

  /// No description provided for @validationSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject'**
  String get validationSelectSubject;

  /// No description provided for @validationSelectTeacher.
  ///
  /// In en, this message translates to:
  /// **'Please select a teacher'**
  String get validationSelectTeacher;

  /// No description provided for @validationSelectRoom.
  ///
  /// In en, this message translates to:
  /// **'Please select a room'**
  String get validationSelectRoom;

  /// No description provided for @noLevelsDefinedYet.
  ///
  /// In en, this message translates to:
  /// **'No levels defined yet.'**
  String get noLevelsDefinedYet;

  /// No description provided for @noSubjectsDefinedYet.
  ///
  /// In en, this message translates to:
  /// **'No subjects defined yet.'**
  String get noSubjectsDefinedYet;

  /// No description provided for @noRoomsAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No rooms added yet'**
  String get noRoomsAddedYet;

  /// No description provided for @noRoomsAddedYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill the form or use Generate to add rooms'**
  String get noRoomsAddedYetSubtitle;

  /// No description provided for @noTeachersAddedYet.
  ///
  /// In en, this message translates to:
  /// **'No teachers added yet'**
  String get noTeachersAddedYet;

  /// No description provided for @noTeachersAddedYetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill in the form and press Add Teacher'**
  String get noTeachersAddedYetSubtitle;

  /// No description provided for @unknownSubject.
  ///
  /// In en, this message translates to:
  /// **'Unknown Subject'**
  String get unknownSubject;

  /// No description provided for @unknownTeacher.
  ///
  /// In en, this message translates to:
  /// **'Unknown Teacher'**
  String get unknownTeacher;

  /// No description provided for @unknownRoom.
  ///
  /// In en, this message translates to:
  /// **'Unknown Room'**
  String get unknownRoom;

  /// No description provided for @roomsAdded.
  ///
  /// In en, this message translates to:
  /// **'Rooms Added'**
  String get roomsAdded;

  /// No description provided for @teachersAdded.
  ///
  /// In en, this message translates to:
  /// **'Teachers Added'**
  String get teachersAdded;

  /// No description provided for @removeRoom.
  ///
  /// In en, this message translates to:
  /// **'Remove room'**
  String get removeRoom;

  /// No description provided for @removeTeacher.
  ///
  /// In en, this message translates to:
  /// **'Remove teacher'**
  String get removeTeacher;

  /// No description provided for @swipeLeftToDeleteRoom.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to delete a room'**
  String get swipeLeftToDeleteRoom;

  /// No description provided for @addRoom.
  ///
  /// In en, this message translates to:
  /// **'Add Room'**
  String get addRoom;

  /// No description provided for @createNewSubject.
  ///
  /// In en, this message translates to:
  /// **'Create new subject'**
  String get createNewSubject;

  /// No description provided for @generateRooms.
  ///
  /// In en, this message translates to:
  /// **'Generate Rooms'**
  String get generateRooms;

  /// No description provided for @generateRoomsDescription.
  ///
  /// In en, this message translates to:
  /// **'Quickly add multiple rooms with a numbered name pattern.'**
  String get generateRoomsDescription;

  /// No description provided for @numberOfRooms.
  ///
  /// In en, this message translates to:
  /// **'Number of rooms'**
  String get numberOfRooms;

  /// No description provided for @numberOfRoomsHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10'**
  String get numberOfRoomsHint;

  /// No description provided for @namePatternLabel.
  ///
  /// In en, this message translates to:
  /// **'Name pattern  (# → number)'**
  String get namePatternLabel;

  /// No description provided for @namePatternHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Room # → Room 1, Room 2…'**
  String get namePatternHint;

  /// No description provided for @helpSheetRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Rooms — Guide'**
  String get helpSheetRoomsTitle;

  /// No description provided for @helpSheetTeachersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher — Guide'**
  String get helpSheetTeachersTitle;

  /// No description provided for @helpSheetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What to enter in each field'**
  String get helpSheetSubtitle;

  /// No description provided for @helpEntryRoomNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get helpEntryRoomNameTitle;

  /// No description provided for @helpEntryRoomNameBody.
  ///
  /// In en, this message translates to:
  /// **'A unique name to identify this room in the schedule.\n\n• At least 2 characters, must be unique\n• Examples: \"Room 101\", \"Science Lab\", \"Computer Room\", \"Library Hall\"'**
  String get helpEntryRoomNameBody;

  /// No description provided for @helpEntryCapacityTitle.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get helpEntryCapacityTitle;

  /// No description provided for @helpEntryCapacityBody.
  ///
  /// In en, this message translates to:
  /// **'The maximum number of students this room can hold at once.\n\n• Leave empty to use the default capacity (40 students)\n• The scheduler uses this to prevent overcrowding\n• Example: Enter \"25\" if the lab only has 25 seats'**
  String get helpEntryCapacityBody;

  /// No description provided for @helpEntryAllowedLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allowed Levels'**
  String get helpEntryAllowedLevelsTitle;

  /// No description provided for @helpEntryAllowedLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'Restrict this room so that only specific school levels can use it.\n\n• Leave all unselected to allow any level\n• Select one or more levels to reserve this room for specific grades\n• Example: A \"Grade 5 Classroom\" reserved only for Grade 5 students'**
  String get helpEntryAllowedLevelsBody;

  /// No description provided for @helpEntryAllowedSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Allowed Subjects'**
  String get helpEntryAllowedSubjectsTitle;

  /// No description provided for @helpEntryAllowedSubjectsBody.
  ///
  /// In en, this message translates to:
  /// **'Restrict this room so only specific subjects can be taught in it.\n\n• Leave all unselected to allow any subject\n• Select subjects if the room has special equipment for certain classes\n• Example: A \"Chemistry Lab\" should only be used for Chemistry'**
  String get helpEntryAllowedSubjectsBody;

  /// No description provided for @helpEntryGenerateRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate Rooms (Quick Action)'**
  String get helpEntryGenerateRoomsTitle;

  /// No description provided for @helpEntryGenerateRoomsBody.
  ///
  /// In en, this message translates to:
  /// **'Use the \"Generate\" button in the toolbar to create many rooms at once.\n\n• Enter how many rooms you need\n• Use # as a placeholder for the room number in the name\n• Example: \"Room #\" with count 5 → creates \"Room 1\" through \"Room 5\"\n• Generated rooms use default capacity (40) with no restrictions'**
  String get helpEntryGenerateRoomsBody;

  /// No description provided for @helpEntryDeletingRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting a Room'**
  String get helpEntryDeletingRoomTitle;

  /// No description provided for @helpEntryDeletingRoomBody.
  ///
  /// In en, this message translates to:
  /// **'You can remove a room from the list after adding it.\n\n• Swipe left on any room tile to delete it\n• Or hover over the tile and tap the 🗑 icon on the right'**
  String get helpEntryDeletingRoomBody;

  /// No description provided for @helpEntryTeacherNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Name'**
  String get helpEntryTeacherNameTitle;

  /// No description provided for @helpEntryTeacherNameBody.
  ///
  /// In en, this message translates to:
  /// **'The full name of the teacher to add to the schedule.\n\n• At least 2 characters, must be unique\n• Examples: \"Sarah Ibrahim\", \"Mr. Ahmed\", \"Dr. Leila\"'**
  String get helpEntryTeacherNameBody;

  /// No description provided for @helpEntryTeacherSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get helpEntryTeacherSubjectTitle;

  /// No description provided for @helpEntryTeacherSubjectBody.
  ///
  /// In en, this message translates to:
  /// **'The subject this teacher is qualified to teach.\n\n• Each teacher is linked to exactly one subject\n• The scheduler uses this to assign the right teacher to each class\n• If the subject is missing, tap \"Create new subject\" to add it first'**
  String get helpEntryTeacherSubjectBody;

  /// No description provided for @helpEntryQualifiedLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Qualified Levels'**
  String get helpEntryQualifiedLevelsTitle;

  /// No description provided for @helpEntryQualifiedLevelsBody.
  ///
  /// In en, this message translates to:
  /// **'The school levels (grades/year groups) this teacher can teach.\n\n• Select at least one level\n• Choose all levels that apply — a teacher can cover multiple levels\n• Example: Select \"Grade 4\" and \"Grade 5\" if the teacher can handle both'**
  String get helpEntryQualifiedLevelsBody;

  /// No description provided for @helpEntryMaxHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Max Hours / Week'**
  String get helpEntryMaxHoursTitle;

  /// No description provided for @helpEntryMaxHoursBody.
  ///
  /// In en, this message translates to:
  /// **'The maximum teaching hours this teacher can have in one week.\n\n• Leave empty for no limit\n• Useful for part-time teachers or to avoid overloading staff\n• Example: Enter \"18\" to cap the teacher at 18 hours/week'**
  String get helpEntryMaxHoursBody;

  /// No description provided for @helpEntryConsecutiveHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Consecutive Hours'**
  String get helpEntryConsecutiveHoursTitle;

  /// No description provided for @helpEntryConsecutiveHoursBody.
  ///
  /// In en, this message translates to:
  /// **'Controls whether this teacher\'s classes should be scheduled back-to-back.\n\n• ✅ Checked — Scheduler groups this teacher\'s lessons in a continuous block\n• ☐ Unchecked — Lessons can be spread freely through the day\n• Useful for teachers who prefer teaching all classes in one session'**
  String get helpEntryConsecutiveHoursBody;

  /// No description provided for @createSubjectEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Select a level and press the + button (Ctrl+A/Cmd+A) to add subjects\nif subject is taught to this level increase the weekly hours else leave it at 0\nread documentation for more info'**
  String get createSubjectEmptyHint;

  /// No description provided for @addSubjectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Subject (Ctrl+A/Cmd+A)'**
  String get addSubjectTooltip;

  /// No description provided for @levelSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected ✓'**
  String get levelSelected;

  /// No description provided for @levelTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get levelTapToSelect;

  /// No description provided for @daySlotHeader.
  ///
  /// In en, this message translates to:
  /// **'Day / Slot'**
  String get daySlotHeader;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'Break Time'**
  String get breakTime;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @selectLevelToViewClasses.
  ///
  /// In en, this message translates to:
  /// **'Select a level to view classes.'**
  String get selectLevelToViewClasses;

  /// No description provided for @selectClassToStartPinning.
  ///
  /// In en, this message translates to:
  /// **'Select a class from the sidebar to start pinning slots.'**
  String get selectClassToStartPinning;

  /// No description provided for @pleaseAddLevelsFirst.
  ///
  /// In en, this message translates to:
  /// **'Please add levels first on the main page.'**
  String get pleaseAddLevelsFirst;

  /// No description provided for @pleaseCompleteWorkingDaysConfig.
  ///
  /// In en, this message translates to:
  /// **'Please complete the working days & timeslots configuration on the first page first.'**
  String get pleaseCompleteWorkingDaysConfig;

  /// No description provided for @templatePlannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Force specific subjects, teachers, and rooms. Pinned classes are strictly respected by the generator.'**
  String get templatePlannerSubtitle;

  /// No description provided for @clearedOverridesForClass.
  ///
  /// In en, this message translates to:
  /// **'Cleared overrides for this class.'**
  String get clearedOverridesForClass;

  /// No description provided for @selectSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a subject first'**
  String get selectSubjectFirst;

  /// No description provided for @noQualifiedTeachersForLevelSubject.
  ///
  /// In en, this message translates to:
  /// **'No qualified teachers for this level & subject'**
  String get noQualifiedTeachersForLevelSubject;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @whileGeneratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the schedule is being generated...'**
  String get whileGeneratingTitle;

  /// No description provided for @whileGeneratingDescription.
  ///
  /// In en, this message translates to:
  /// **'Once the schedule is generated, you will be redirected to the schedule details page.\nThe solver (algorithm) will be running in the server trying all possible combinations to find the OPTIMAL solution. \nA lack of resources will lead to FEASIBLE not OPTIMAL solutions or unfeasible at all.'**
  String get whileGeneratingDescription;

  /// No description provided for @whileGeneratingWarning.
  ///
  /// In en, this message translates to:
  /// **'If it takes too long, that means the solver is going to fail'**
  String get whileGeneratingWarning;

  /// No description provided for @generatingStatusInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing schedule generation...'**
  String get generatingStatusInitializing;

  /// No description provided for @generatingStatusEvaluating.
  ///
  /// In en, this message translates to:
  /// **'Evaluating constraints...'**
  String get generatingStatusEvaluating;

  /// No description provided for @generatingStatusSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for the optimal schedule...'**
  String get generatingStatusSearching;

  /// No description provided for @generatingStatusOptimizing.
  ///
  /// In en, this message translates to:
  /// **'Optimizing timetable...'**
  String get generatingStatusOptimizing;

  /// No description provided for @generatingStatusFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing schedule...'**
  String get generatingStatusFinalizing;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {duration}'**
  String estimatedTime(String duration);

  /// No description provided for @estimatedTimeMinSec.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min {seconds} sec'**
  String estimatedTimeMinSec(int minutes, int seconds);

  /// No description provided for @estimatedTimeSec.
  ///
  /// In en, this message translates to:
  /// **'{seconds} sec'**
  String estimatedTimeSec(int seconds);

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Perfect\nClass Schedules\nin Minutes'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop wrestling with spreadsheets. seg-timetable automatically assigns teachers, rooms and time-slots so every class gets the schedule it deserves — conflict-free.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeInstitutionNotice.
  ///
  /// In en, this message translates to:
  /// **'Mainly created for schools, but can be used by any institution that needs timetables.'**
  String get homeInstitutionNotice;

  /// No description provided for @homeCtaButton.
  ///
  /// In en, this message translates to:
  /// **'Create Your Schedule'**
  String get homeCtaButton;

  /// No description provided for @homeSocialProof.
  ///
  /// In en, this message translates to:
  /// **'Free to get started · No account required'**
  String get homeSocialProof;

  /// No description provided for @homeWeeklySchedulePreview.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule Preview'**
  String get homeWeeklySchedulePreview;

  /// No description provided for @homeFeaturesTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to schedule smarter'**
  String get homeFeaturesTitle;

  /// No description provided for @homeFeaturesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powerful features packed into a clean, intuitive interface.'**
  String get homeFeaturesSubtitle;

  /// No description provided for @homeFeatureInstantGenerationTitle.
  ///
  /// In en, this message translates to:
  /// **'Instant Generation'**
  String get homeFeatureInstantGenerationTitle;

  /// No description provided for @homeFeatureInstantGenerationDesc.
  ///
  /// In en, this message translates to:
  /// **'Our algorithm processes your constraints and produces a complete, conflict-free timetable in seconds.'**
  String get homeFeatureInstantGenerationDesc;

  /// No description provided for @homeFeatureTeacherRoomTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher & Room Management'**
  String get homeFeatureTeacherRoomTitle;

  /// No description provided for @homeFeatureTeacherRoomDesc.
  ///
  /// In en, this message translates to:
  /// **'Add teachers, define subjects and assign rooms. The scheduler respects availability and capacity.'**
  String get homeFeatureTeacherRoomDesc;

  /// No description provided for @homeFeatureManualOverridesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Overrides'**
  String get homeFeatureManualOverridesTitle;

  /// No description provided for @homeFeatureManualOverridesDesc.
  ///
  /// In en, this message translates to:
  /// **'Need to pin a specific slot? Use the manual override planner to lock assignments while keeping the rest optimised.'**
  String get homeFeatureManualOverridesDesc;

  /// No description provided for @homeFeatureExportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get homeFeatureExportPdfTitle;

  /// No description provided for @homeFeatureExportPdfDesc.
  ///
  /// In en, this message translates to:
  /// **'Print or share your schedule as a professional PDF with one click — ready for notice boards or staff emails.'**
  String get homeFeatureExportPdfDesc;

  /// No description provided for @homeHowItWorksChip.
  ///
  /// In en, this message translates to:
  /// **'HOW IT WORKS'**
  String get homeHowItWorksChip;

  /// No description provided for @homeHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'From blank page to published schedule\nin four simple steps'**
  String get homeHowItWorksTitle;

  /// No description provided for @homeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Set Timing Constraints'**
  String get homeStep1Title;

  /// No description provided for @homeStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Choose your working days, define start and end hours, and mark any break periods.'**
  String get homeStep1Desc;

  /// No description provided for @homeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Add Teachers, Subjects & Rooms'**
  String get homeStep2Title;

  /// No description provided for @homeStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Input all the people and resources the scheduler needs to work with.'**
  String get homeStep2Desc;

  /// No description provided for @homeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get homeStep3Title;

  /// No description provided for @homeStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Hit generate and watch the algorithm build a perfectly balanced schedule for every class.'**
  String get homeStep3Desc;

  /// No description provided for @homeStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Review & Export'**
  String get homeStep4Title;

  /// No description provided for @homeStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'Inspect the result, apply any manual overrides, then export a polished PDF.'**
  String get homeStep4Desc;

  /// No description provided for @homeStartForFree.
  ///
  /// In en, this message translates to:
  /// **'Start for free'**
  String get homeStartForFree;

  /// No description provided for @homeBottomCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to build your first schedule?'**
  String get homeBottomCtaTitle;

  /// No description provided for @homeBottomCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It only takes a few minutes to configure your school and let the algorithm do the heavy lifting.'**
  String get homeBottomCtaSubtitle;

  /// No description provided for @homeBottomCtaButton.
  ///
  /// In en, this message translates to:
  /// **'Create Your Schedule Now'**
  String get homeBottomCtaButton;

  /// No description provided for @homeCopyright.
  ///
  /// In en, this message translates to:
  /// **'Lkout © 2026'**
  String get homeCopyright;

  /// No description provided for @startFreshTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh?'**
  String get startFreshTitle;

  /// No description provided for @startFreshContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all saved data including teachers, subjects, rooms, and schedule settings. Are you sure?'**
  String get startFreshContent;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @startFresh.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get startFresh;

  /// No description provided for @lastGenerated.
  ///
  /// In en, this message translates to:
  /// **'Last Generated'**
  String get lastGenerated;

  /// No description provided for @selectWorkingDays.
  ///
  /// In en, this message translates to:
  /// **'Select Working Days'**
  String get selectWorkingDays;

  /// No description provided for @pleaseSelectOneDayOrderMatters.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day — ORDER MATTERS:'**
  String get pleaseSelectOneDayOrderMatters;

  /// No description provided for @workingHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Working Hours  (e.g. 8 = 08:00)'**
  String get workingHoursTitle;

  /// No description provided for @workingHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the first and last hour of the school day.'**
  String get workingHoursHint;

  /// No description provided for @startHourRequired.
  ///
  /// In en, this message translates to:
  /// **'Start hour is required'**
  String get startHourRequired;

  /// No description provided for @enterWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get enterWholeNumber;

  /// No description provided for @mustBeBetween1And22.
  ///
  /// In en, this message translates to:
  /// **'Must be between 1 and 22'**
  String get mustBeBetween1And22;

  /// No description provided for @startHourLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get startHourLabel;

  /// No description provided for @endHourRequired.
  ///
  /// In en, this message translates to:
  /// **'End hour is required'**
  String get endHourRequired;

  /// No description provided for @cannotExceed23.
  ///
  /// In en, this message translates to:
  /// **'Cannot exceed 23'**
  String get cannotExceed23;

  /// No description provided for @mustBeAfterStartHour.
  ///
  /// In en, this message translates to:
  /// **'Must be after start hour'**
  String get mustBeAfterStartHour;

  /// No description provided for @endHourLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get endHourLabel;

  /// No description provided for @timeslotsFormula.
  ///
  /// In en, this message translates to:
  /// **'Timeslots = end hour − start hour'**
  String get timeslotsFormula;

  /// No description provided for @maxHoursPerStudentPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max Hours per Student per Day'**
  String get maxHoursPerStudentPerDay;

  /// No description provided for @maxHoursPerDayHint.
  ///
  /// In en, this message translates to:
  /// **'A class cannot be scheduled for more hours than this value in a single day.'**
  String get maxHoursPerDayHint;

  /// No description provided for @pleaseSelectValidValue.
  ///
  /// In en, this message translates to:
  /// **'Please select a valid value (1 or more)'**
  String get pleaseSelectValidValue;

  /// No description provided for @breakHoursTitle.
  ///
  /// In en, this message translates to:
  /// **'Break Hours'**
  String get breakHoursTitle;

  /// No description provided for @breakHoursHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Lunch 12:00–14:00 → select 12 and 13.'**
  String get breakHoursHint;

  /// No description provided for @pleaseSelectStartAndEndHoursFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select start and end hours first'**
  String get pleaseSelectStartAndEndHoursFirst;

  /// No description provided for @breakHourMustBeAfterStartHour.
  ///
  /// In en, this message translates to:
  /// **'Break hour must be after start hour'**
  String get breakHourMustBeAfterStartHour;

  /// No description provided for @breakHourMustBeBeforeEndHour.
  ///
  /// In en, this message translates to:
  /// **'Break hour must be before end hour'**
  String get breakHourMustBeBeforeEndHour;

  /// No description provided for @breakSlots.
  ///
  /// In en, this message translates to:
  /// **'Break slots:'**
  String get breakSlots;

  /// No description provided for @noBreakHoursSelected.
  ///
  /// In en, this message translates to:
  /// **'No break hours selected'**
  String get noBreakHoursSelected;

  /// No description provided for @editSpecificDaySlots.
  ///
  /// In en, this message translates to:
  /// **'Edit Specific Day Slots'**
  String get editSpecificDaySlots;

  /// No description provided for @clickDayToManageSlots.
  ///
  /// In en, this message translates to:
  /// **'Click a day to manage its active slots.'**
  String get clickDayToManageSlots;

  /// No description provided for @noDaysSelected.
  ///
  /// In en, this message translates to:
  /// **'No days selected'**
  String get noDaysSelected;

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Schedule Summary'**
  String get scheduleSummary;

  /// No description provided for @summaryDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Days per week'**
  String get summaryDaysPerWeek;

  /// No description provided for @summaryTimeslotsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Timeslots / day'**
  String get summaryTimeslotsPerDay;

  /// No description provided for @summaryMaxHoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max hours / day'**
  String get summaryMaxHoursPerDay;

  /// No description provided for @summaryBreakHours.
  ///
  /// In en, this message translates to:
  /// **'Break hours'**
  String get summaryBreakHours;

  /// No description provided for @summarySelectedDays.
  ///
  /// In en, this message translates to:
  /// **'Selected days'**
  String get summarySelectedDays;

  /// No description provided for @nextLabel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLabel;

  /// No description provided for @nextStageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Next stage'**
  String get nextStageTooltip;

  /// No description provided for @startByAddingLevels.
  ///
  /// In en, this message translates to:
  /// **'Start by adding levels'**
  String get startByAddingLevels;

  /// No description provided for @addLevelsInstructions.
  ///
  /// In en, this message translates to:
  /// **'First add levels, then subjects, then rooms, then manual overrides'**
  String get addLevelsInstructions;

  /// No description provided for @addLevels.
  ///
  /// In en, this message translates to:
  /// **'Add levels'**
  String get addLevels;

  /// No description provided for @levelsColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levelsColumnHeader;

  /// No description provided for @addLevel.
  ///
  /// In en, this message translates to:
  /// **'Add Level'**
  String get addLevel;

  /// No description provided for @removeLevelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove level'**
  String get removeLevelTooltip;

  /// No description provided for @selectLevelToViewDetailsHeader.
  ///
  /// In en, this message translates to:
  /// **'Select a level to view details'**
  String get selectLevelToViewDetailsHeader;

  /// No description provided for @detailsForLevel.
  ///
  /// In en, this message translates to:
  /// **'Details for {level}'**
  String detailsForLevel(String level);

  /// No description provided for @subjectsTaught.
  ///
  /// In en, this message translates to:
  /// **'Subjects Taught'**
  String get subjectsTaught;

  /// No description provided for @assignedTeachers.
  ///
  /// In en, this message translates to:
  /// **'Assigned Teachers'**
  String get assignedTeachers;

  /// No description provided for @availableRooms.
  ///
  /// In en, this message translates to:
  /// **'Available Rooms'**
  String get availableRooms;

  /// No description provided for @manualOverridesSection.
  ///
  /// In en, this message translates to:
  /// **'Manual Overrides'**
  String get manualOverridesSection;

  /// No description provided for @noManualOverridesForLevel.
  ///
  /// In en, this message translates to:
  /// **'No manual overrides configured for this level.'**
  String get noManualOverridesForLevel;

  /// No description provided for @activeOverrideConstraints.
  ///
  /// In en, this message translates to:
  /// **'{count} active override constraint(s) pinned for classes in this level.'**
  String activeOverrideConstraints(int count);

  /// No description provided for @pleaseSelectLevelFromLeft.
  ///
  /// In en, this message translates to:
  /// **'Please select a level from the left to view and manage\nits subjects, teachers, and rooms.'**
  String get pleaseSelectLevelFromLeft;

  /// No description provided for @allRoomsForcedNoFreeRooms.
  ///
  /// In en, this message translates to:
  /// **'All rooms are forced for specific subjects, leaving no free rooms for the remaining subjects.'**
  String get allRoomsForcedNoFreeRooms;

  /// No description provided for @hasNoTeacher.
  ///
  /// In en, this message translates to:
  /// **'has no teacher'**
  String get hasNoTeacher;

  /// No description provided for @needHoursNoQualifiedTeacher.
  ///
  /// In en, this message translates to:
  /// **'{level} needs {hours} hours of \"{subject}\" but no teacher is qualified, add teacher to level {level}'**
  String needHoursNoQualifiedTeacher(int hours, String subject, String level);

  /// No description provided for @notEnoughTeachersContent.
  ///
  /// In en, this message translates to:
  /// **'Not enough teachers for {subject}!\n\n• Required: {required} hours\n• Available capacity: {available} hours\n\nConsider adding ~{needed} more teacher(s).'**
  String notEnoughTeachersContent(
    String subject,
    int required,
    int available,
    int needed,
  );

  /// No description provided for @insufficientRoomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Rooms'**
  String get insufficientRoomsTitle;

  /// No description provided for @roomCapacityMayBeInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Room capacity may be insufficient'**
  String get roomCapacityMayBeInsufficient;

  /// No description provided for @currentRooms.
  ///
  /// In en, this message translates to:
  /// **'Current rooms:'**
  String get currentRooms;

  /// No description provided for @predictedNeeded.
  ///
  /// In en, this message translates to:
  /// **'Predicted needed:'**
  String get predictedNeeded;

  /// No description provided for @totalClassHoursWeek.
  ///
  /// In en, this message translates to:
  /// **'Total class-hours/week:'**
  String get totalClassHoursWeek;

  /// No description provided for @ratioPerRoom.
  ///
  /// In en, this message translates to:
  /// **'Ratio per room:'**
  String get ratioPerRoom;

  /// No description provided for @schedulerMayFail.
  ///
  /// In en, this message translates to:
  /// **'The scheduler may fail to find a solution. Consider adding more rooms.'**
  String get schedulerMayFail;

  /// No description provided for @classesCount.
  ///
  /// In en, this message translates to:
  /// **'Classes: {count}'**
  String classesCount(int count);

  /// No description provided for @pdfLockedSlot.
  ///
  /// In en, this message translates to:
  /// **'lock'**
  String get pdfLockedSlot;

  /// No description provided for @pdfDocumentName.
  ///
  /// In en, this message translates to:
  /// **'My_Document'**
  String get pdfDocumentName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noScheduleDataGoHome.
  ///
  /// In en, this message translates to:
  /// **'No schedule data found. Returning home...'**
  String get noScheduleDataGoHome;

  /// No description provided for @selectAClass.
  ///
  /// In en, this message translates to:
  /// **'Select a class'**
  String get selectAClass;

  /// No description provided for @selectClassToViewSchedule.
  ///
  /// In en, this message translates to:
  /// **'Select a class from the list to view its schedule.'**
  String get selectClassToViewSchedule;

  /// No description provided for @scheduleGenerationFailed.
  ///
  /// In en, this message translates to:
  /// **'Schedule generation failed.'**
  String get scheduleGenerationFailed;

  /// No description provided for @generalCategory.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalCategory;

  /// No description provided for @noDetailsProvided.
  ///
  /// In en, this message translates to:
  /// **'No details provided.'**
  String get noDetailsProvided;

  /// No description provided for @noFurtherDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'No further diagnostics available.'**
  String get noFurtherDiagnostics;

  /// No description provided for @solutionHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: {hint}'**
  String solutionHint(String hint);

  /// No description provided for @clsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} class(es)'**
  String clsCount(int count);

  /// No description provided for @saveExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveExit;

  /// No description provided for @clickToAddHeaderImage.
  ///
  /// In en, this message translates to:
  /// **'Click to add header image'**
  String get clickToAddHeaderImage;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dearUser.
  ///
  /// In en, this message translates to:
  /// **'Dear User'**
  String get dearUser;

  /// No description provided for @paymentWorkInProgress.
  ///
  /// In en, this message translates to:
  /// **'Payment integration is currently in progress. Please contact us directly to complete your purchase.'**
  String get paymentWorkInProgress;

  /// No description provided for @paymentIntegrationMessage.
  ///
  /// In en, this message translates to:
  /// **'We are currently still working on payment integration.\nWe apologize for the inconvenience. We will be back soon with a better solution. Thank you for your patience.'**
  String get paymentIntegrationMessage;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: abdoullouahd@gmail.com'**
  String get contactEmail;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone: +212628503463'**
  String get contactPhone;

  /// No description provided for @thankYouForUnderstanding.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your understanding!'**
  String get thankYouForUnderstanding;

  /// No description provided for @amountDisplay.
  ///
  /// In en, this message translates to:
  /// **'Amount: 299 MAD'**
  String get amountDisplay;

  /// No description provided for @feesDisplay.
  ///
  /// In en, this message translates to:
  /// **'Fees: {fees} MAD'**
  String feesDisplay(String fees);

  /// No description provided for @totalDisplay.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} MAD'**
  String totalDisplay(String total);

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed: {error}'**
  String paymentFailed(String error);

  /// No description provided for @unlockFullPotential.
  ///
  /// In en, this message translates to:
  /// **'Unlock the Full Potential'**
  String get unlockFullPotential;

  /// No description provided for @fullAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Get full access to all features and generate unlimited schedules.'**
  String get fullAccessDescription;

  /// No description provided for @getFullAccess.
  ///
  /// In en, this message translates to:
  /// **'Get full access to your schedule without restrictions.'**
  String get getFullAccess;

  /// No description provided for @premiumAccess.
  ///
  /// In en, this message translates to:
  /// **'Premium Access'**
  String get premiumAccess;

  /// No description provided for @perEightMonths.
  ///
  /// In en, this message translates to:
  /// **'/ 8 months'**
  String get perEightMonths;

  /// No description provided for @featureRemoveLockedSlots.
  ///
  /// In en, this message translates to:
  /// **'Remove locked slots'**
  String get featureRemoveLockedSlots;

  /// No description provided for @featureExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export to PDF'**
  String get featureExportPdf;

  /// No description provided for @featureAnyDevice.
  ///
  /// In en, this message translates to:
  /// **'Access on any device'**
  String get featureAnyDevice;

  /// No description provided for @featureManualOverrides.
  ///
  /// In en, this message translates to:
  /// **'Manual overrides'**
  String get featureManualOverrides;

  /// No description provided for @featurePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get featurePrioritySupport;

  /// No description provided for @removeLockedSlots.
  ///
  /// In en, this message translates to:
  /// **'Remove all locked slots'**
  String get removeLockedSlots;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export schedule to high-quality PDF'**
  String get exportPdf;

  /// No description provided for @anyDevice.
  ///
  /// In en, this message translates to:
  /// **'Get your schedule on any device'**
  String get anyDevice;

  /// No description provided for @advancedOverrides.
  ///
  /// In en, this message translates to:
  /// **'Advanced manual overrides'**
  String get advancedOverrides;

  /// No description provided for @prioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority customer support'**
  String get prioritySupport;

  /// No description provided for @upgradeNow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @demoLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo Limit Reached'**
  String get demoLimitTitle;

  /// No description provided for @demoLimitContent.
  ///
  /// In en, this message translates to:
  /// **'The demo version only supports schedules with fewer than 30 classes. Sign in or upgrade to Premium to generate schedules with 30 or more classes.'**
  String get demoLimitContent;

  /// No description provided for @signInOrUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Upgrade'**
  String get signInOrUpgrade;

  /// No description provided for @segtimetableDescription.
  ///
  /// In en, this message translates to:
  /// **'A modern platform for managing school timetables with simplicity and efficiency.'**
  String get segtimetableDescription;

  /// No description provided for @featureTimetablesTitle.
  ///
  /// In en, this message translates to:
  /// **'School Timetables'**
  String get featureTimetablesTitle;

  /// No description provided for @featureTimetablesDesc.
  ///
  /// In en, this message translates to:
  /// **'Create and manage school timetables easily.'**
  String get featureTimetablesDesc;

  /// No description provided for @featureSecureTitle.
  ///
  /// In en, this message translates to:
  /// **'Secure & Reliable'**
  String get featureSecureTitle;

  /// No description provided for @featureSecureDesc.
  ///
  /// In en, this message translates to:
  /// **'Your information is protected and safely stored.'**
  String get featureSecureDesc;

  /// No description provided for @featureSaveTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Time'**
  String get featureSaveTimeTitle;

  /// No description provided for @featureSaveTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize schedules faster with a streamlined workflow.'**
  String get featureSaveTimeDesc;

  /// No description provided for @featureSimpleTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Experience'**
  String get featureSimpleTitle;

  /// No description provided for @featureSimpleDesc.
  ///
  /// In en, this message translates to:
  /// **'An intuitive interface designed for everyone.'**
  String get featureSimpleDesc;

  /// No description provided for @segtimetableQuote.
  ///
  /// In en, this message translates to:
  /// **'Organizing timetables, so you can focus on teaching.'**
  String get segtimetableQuote;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please sign in to your account.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account by filling in the details below.'**
  String get signUpSubtitle;

  /// No description provided for @requestTimedOut.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please check your connection and try again.'**
  String get requestTimedOut;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unexpectedError;

  /// No description provided for @resetPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for this email, a reset link has been sent.'**
  String get resetPasswordSuccess;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @eraseSavedScheduleWarning.
  ///
  /// In en, this message translates to:
  /// **'Generating a new schedule will erase the saved one.'**
  String get eraseSavedScheduleWarning;

  /// No description provided for @impossibleToRecreate.
  ///
  /// In en, this message translates to:
  /// **'It\'s nearly impossible to generate same schedule twice.'**
  String get impossibleToRecreate;

  /// No description provided for @sureToContinue.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to continue?'**
  String get sureToContinue;

  /// No description provided for @loadLastCreatedSchedule.
  ///
  /// In en, this message translates to:
  /// **'Load Last Created Schedule'**
  String get loadLastCreatedSchedule;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @exitCreator.
  ///
  /// In en, this message translates to:
  /// **'Exit Creator'**
  String get exitCreator;

  /// No description provided for @exitConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your unsaved changes will be lost.'**
  String get exitConfirmMessage;

  /// No description provided for @exitBtn.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitBtn;

  /// No description provided for @hintStartHour.
  ///
  /// In en, this message translates to:
  /// **'e.g. 8'**
  String get hintStartHour;

  /// No description provided for @hintEndHour.
  ///
  /// In en, this message translates to:
  /// **'e.g. 17'**
  String get hintEndHour;

  /// No description provided for @validationLevelNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Level name is required'**
  String get validationLevelNameRequired;

  /// No description provided for @validationLevelAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This level already exists'**
  String get validationLevelAlreadyExists;

  /// No description provided for @validationClassesRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of classes is required'**
  String get validationClassesRequired;

  /// No description provided for @labelLevelName.
  ///
  /// In en, this message translates to:
  /// **'Level name'**
  String get labelLevelName;

  /// No description provided for @hintLevelName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Primary 1'**
  String get hintLevelName;

  /// No description provided for @labelNumberOfClasses.
  ///
  /// In en, this message translates to:
  /// **'Number of classes'**
  String get labelNumberOfClasses;

  /// No description provided for @hintNumberOfClasses.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get hintNumberOfClasses;

  /// No description provided for @validationSubjectNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject name is required'**
  String get validationSubjectNameRequired;

  /// No description provided for @validationSubjectAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Subject already exists'**
  String get validationSubjectAlreadyExists;

  /// No description provided for @hintSubjectName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics'**
  String get hintSubjectName;

  /// No description provided for @validationNonNegativeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a non-negative number'**
  String get validationNonNegativeNumber;

  /// No description provided for @validationCommaSeparatedNumbers.
  ///
  /// In en, this message translates to:
  /// **'Enter comma-separated numbers'**
  String get validationCommaSeparatedNumbers;

  /// No description provided for @subjectColor.
  ///
  /// In en, this message translates to:
  /// **'Subject color'**
  String get subjectColor;

  /// No description provided for @advancedParameters.
  ///
  /// In en, this message translates to:
  /// **'Advanced parameters'**
  String get advancedParameters;

  /// No description provided for @minimumRestHours.
  ///
  /// In en, this message translates to:
  /// **'Minimum rest hours'**
  String get minimumRestHours;

  /// No description provided for @avoidHours.
  ///
  /// In en, this message translates to:
  /// **'Avoid hours'**
  String get avoidHours;

  /// No description provided for @avoidHoursHint.
  ///
  /// In en, this message translates to:
  /// **'Optional, e.g. 1, 3, 5'**
  String get avoidHoursHint;

  /// No description provided for @validationRoomAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Room already exists'**
  String get validationRoomAlreadyExists;

  /// No description provided for @hintRoomName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Room 101'**
  String get hintRoomName;

  /// No description provided for @validationNumberOfRoomsRequired.
  ///
  /// In en, this message translates to:
  /// **'Number of rooms is required'**
  String get validationNumberOfRoomsRequired;

  /// No description provided for @titleUpdateMinutes.
  ///
  /// In en, this message translates to:
  /// **'Update Minutes'**
  String get titleUpdateMinutes;

  /// No description provided for @labelMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get labelMinutes;

  /// No description provided for @btnUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get btnUpdate;

  /// No description provided for @isNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Is Not Scheduled'**
  String get isNotScheduled;

  /// No description provided for @lessThanNClasses.
  ///
  /// In en, this message translates to:
  /// **'Less than {count} classes'**
  String lessThanNClasses(int count);

  /// No description provided for @approxNStudents.
  ///
  /// In en, this message translates to:
  /// **'Approx {count} students'**
  String approxNStudents(int count);

  /// No description provided for @contactUsForAgreement.
  ///
  /// In en, this message translates to:
  /// **'Contact us to set an agreement'**
  String get contactUsForAgreement;

  /// No description provided for @titleSchoolBasic.
  ///
  /// In en, this message translates to:
  /// **'School Basic'**
  String get titleSchoolBasic;

  /// No description provided for @titleSchoolStandard.
  ///
  /// In en, this message translates to:
  /// **'School Standard'**
  String get titleSchoolStandard;

  /// No description provided for @titleSchoolPremium.
  ///
  /// In en, this message translates to:
  /// **'School Premium'**
  String get titleSchoolPremium;

  /// No description provided for @titleCustomAgreement.
  ///
  /// In en, this message translates to:
  /// **'Custom Agreement'**
  String get titleCustomAgreement;

  /// No description provided for @badgePopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get badgePopular;

  /// No description provided for @priceAgreement.
  ///
  /// In en, this message translates to:
  /// **'Agreement'**
  String get priceAgreement;

  /// No description provided for @featureFlexibleClassCounts.
  ///
  /// In en, this message translates to:
  /// **'Flexible class counts'**
  String get featureFlexibleClassCounts;

  /// No description provided for @featureFlexibleStudentCounts.
  ///
  /// In en, this message translates to:
  /// **'Flexible student counts'**
  String get featureFlexibleStudentCounts;

  /// No description provided for @featureExamCorrection.
  ///
  /// In en, this message translates to:
  /// **'Exam correction'**
  String get featureExamCorrection;

  /// No description provided for @featureAbsenceManagement.
  ///
  /// In en, this message translates to:
  /// **'Absence management'**
  String get featureAbsenceManagement;

  /// No description provided for @featureLessonsPlanner.
  ///
  /// In en, this message translates to:
  /// **'Lessons planner'**
  String get featureLessonsPlanner;

  /// No description provided for @btnContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get btnContactUs;

  /// No description provided for @licenseError.
  ///
  /// In en, this message translates to:
  /// **'License Error'**
  String get licenseError;

  /// No description provided for @getALicense.
  ///
  /// In en, this message translates to:
  /// **'Get a License'**
  String get getALicense;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {uri}'**
  String routeNotFound(String uri);

  /// No description provided for @aboutHomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get aboutHomeTooltip;

  /// No description provided for @aboutAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'About Seg-Dude'**
  String get aboutAppBarTitle;

  /// No description provided for @aboutHeroChip.
  ///
  /// In en, this message translates to:
  /// **'OUR STORY'**
  String get aboutHeroChip;

  /// No description provided for @aboutHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'About Seg-Dude'**
  String get aboutHeroTitle;

  /// No description provided for @aboutHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simplifying school management through smart, modern technology.'**
  String get aboutHeroSubtitle;

  /// No description provided for @aboutScrollToExplore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to explore'**
  String get aboutScrollToExplore;

  /// No description provided for @aboutWhoWeAreChip.
  ///
  /// In en, this message translates to:
  /// **'WHO WE ARE'**
  String get aboutWhoWeAreChip;

  /// No description provided for @aboutWhoWeAreTitle.
  ///
  /// In en, this message translates to:
  /// **'Who We Are'**
  String get aboutWhoWeAreTitle;

  /// No description provided for @aboutWhoWeAreDescription.
  ///
  /// In en, this message translates to:
  /// **'Seg-Dude is a modern school management platform designed to simplify the daily operations of educational institutions. Our goal is to provide an efficient, secure, and user-friendly solution that connects school administrators, teachers, students, and parents through an intuitive digital experience.'**
  String get aboutWhoWeAreDescription;

  /// No description provided for @aboutOurMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get aboutOurMissionTitle;

  /// No description provided for @aboutOurMissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Our mission is to make school management easier by providing practical digital tools that improve organization, simplify scheduling, and support a better educational environment for schools.'**
  String get aboutOurMissionDescription;

  /// No description provided for @aboutWhatWeOfferChip.
  ///
  /// In en, this message translates to:
  /// **'WHAT WE OFFER'**
  String get aboutWhatWeOfferChip;

  /// No description provided for @aboutWhatWeOfferTitle.
  ///
  /// In en, this message translates to:
  /// **'What We Offer'**
  String get aboutWhatWeOfferTitle;

  /// No description provided for @aboutFeatureTeacherManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Management'**
  String get aboutFeatureTeacherManagementTitle;

  /// No description provided for @aboutFeatureTeacherManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Organize teacher profiles, availability, and workload.'**
  String get aboutFeatureTeacherManagementDesc;

  /// No description provided for @aboutFeatureClassSchedulingTitle.
  ///
  /// In en, this message translates to:
  /// **'Class Scheduling'**
  String get aboutFeatureClassSchedulingTitle;

  /// No description provided for @aboutFeatureClassSchedulingDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate conflict-free schedules in a few clicks.'**
  String get aboutFeatureClassSchedulingDesc;

  /// No description provided for @aboutFeatureSimpleInterfaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple & Modern Interface'**
  String get aboutFeatureSimpleInterfaceTitle;

  /// No description provided for @aboutFeatureSimpleInterfaceDesc.
  ///
  /// In en, this message translates to:
  /// **'A clean experience built for everyday school staff.'**
  String get aboutFeatureSimpleInterfaceDesc;

  /// No description provided for @aboutFeatureFastWorkflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast and Organized Workflow'**
  String get aboutFeatureFastWorkflowTitle;

  /// No description provided for @aboutFeatureFastWorkflowDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce manual work and keep everything in one place.'**
  String get aboutFeatureFastWorkflowDesc;

  /// No description provided for @aboutComingSoonChip.
  ///
  /// In en, this message translates to:
  /// **'COMING SOON'**
  String get aboutComingSoonChip;

  /// No description provided for @aboutWhatsNextTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s Next'**
  String get aboutWhatsNextTitle;

  /// No description provided for @aboutComingSoonIntro.
  ///
  /// In en, this message translates to:
  /// **'Seg-Dude is continuously evolving. Here\'s a glimpse of what we\'re building next.'**
  String get aboutComingSoonIntro;

  /// No description provided for @aboutComingSoonFooter.
  ///
  /// In en, this message translates to:
  /// **'Seg-Dude is continuously evolving. We\'re working on new features that will make school management even smarter and more efficient.'**
  String get aboutComingSoonFooter;

  /// No description provided for @aboutSoonBadge.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get aboutSoonBadge;

  /// No description provided for @aboutComingSoonStudentManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Management'**
  String get aboutComingSoonStudentManagementTitle;

  /// No description provided for @aboutComingSoonStudentManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Full student profiles and records in one place.'**
  String get aboutComingSoonStudentManagementDesc;

  /// No description provided for @aboutComingSoonAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance System'**
  String get aboutComingSoonAttendanceTitle;

  /// No description provided for @aboutComingSoonAttendanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Track presence and absence with ease.'**
  String get aboutComingSoonAttendanceDesc;

  /// No description provided for @aboutComingSoonGradeManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Management'**
  String get aboutComingSoonGradeManagementTitle;

  /// No description provided for @aboutComingSoonGradeManagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Record and analyze student performance.'**
  String get aboutComingSoonGradeManagementDesc;

  /// No description provided for @aboutComingSoonParentPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Portal'**
  String get aboutComingSoonParentPortalTitle;

  /// No description provided for @aboutComingSoonParentPortalDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep parents informed and engaged.'**
  String get aboutComingSoonParentPortalDesc;

  /// No description provided for @aboutComingSoonNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get aboutComingSoonNotificationsTitle;

  /// No description provided for @aboutComingSoonNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Timely alerts for staff, students, and parents.'**
  String get aboutComingSoonNotificationsDesc;

  /// No description provided for @aboutComingSoonAiToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered Educational Tools'**
  String get aboutComingSoonAiToolsTitle;

  /// No description provided for @aboutComingSoonAiToolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Smart assistance for everyday school tasks.'**
  String get aboutComingSoonAiToolsDesc;

  /// No description provided for @aboutOurVisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get aboutOurVisionTitle;

  /// No description provided for @aboutOurVisionDescription.
  ///
  /// In en, this message translates to:
  /// **'We envision a future where every educational institution can manage its daily activities efficiently through innovative technology that saves time, reduces complexity, and supports academic success.'**
  String get aboutOurVisionDescription;

  /// No description provided for @aboutOurValuesChip.
  ///
  /// In en, this message translates to:
  /// **'OUR VALUES'**
  String get aboutOurValuesChip;

  /// No description provided for @aboutOurValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Values'**
  String get aboutOurValuesTitle;

  /// No description provided for @aboutValueInnovationTitle.
  ///
  /// In en, this message translates to:
  /// **'Innovation'**
  String get aboutValueInnovationTitle;

  /// No description provided for @aboutValueInnovationDesc.
  ///
  /// In en, this message translates to:
  /// **'Bringing modern technology to everyday school needs.'**
  String get aboutValueInnovationDesc;

  /// No description provided for @aboutValueSimplicityTitle.
  ///
  /// In en, this message translates to:
  /// **'Simplicity'**
  String get aboutValueSimplicityTitle;

  /// No description provided for @aboutValueSimplicityDesc.
  ///
  /// In en, this message translates to:
  /// **'Keeping tools intuitive and easy to use.'**
  String get aboutValueSimplicityDesc;

  /// No description provided for @aboutValueReliabilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get aboutValueReliabilityTitle;

  /// No description provided for @aboutValueReliabilityDesc.
  ///
  /// In en, this message translates to:
  /// **'Building solutions schools can depend on.'**
  String get aboutValueReliabilityDesc;

  /// No description provided for @aboutValueSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get aboutValueSecurityTitle;

  /// No description provided for @aboutValueSecurityDesc.
  ///
  /// In en, this message translates to:
  /// **'Protecting school and student data at every step.'**
  String get aboutValueSecurityDesc;

  /// No description provided for @aboutStayConnectedChip.
  ///
  /// In en, this message translates to:
  /// **'STAY CONNECTED'**
  String get aboutStayConnectedChip;

  /// No description provided for @aboutConnectWithUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get aboutConnectWithUsTitle;

  /// No description provided for @connectWithUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect With Us'**
  String get connectWithUsTitle;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @supportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have questions or need help? Contact us directly.'**
  String get supportSubtitle;

  /// No description provided for @emailUs.
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get emailUs;

  /// No description provided for @sendUsEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Send us email and we will reply as soon as possible'**
  String get sendUsEmailMessage;

  /// No description provided for @aboutConnectWithUsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Seg-Dude for tutorials, product updates, announcements, and new educational content.'**
  String get aboutConnectWithUsSubtitle;

  /// No description provided for @aboutYouTubePlatform.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get aboutYouTubePlatform;

  /// No description provided for @aboutYouTubeActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Visit channel'**
  String get aboutYouTubeActionLabel;

  /// No description provided for @aboutYouTubeDescription.
  ///
  /// In en, this message translates to:
  /// **'Watch tutorials, feature walkthroughs, updates, and future videos.'**
  String get aboutYouTubeDescription;

  /// No description provided for @aboutInstagramPlatform.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get aboutInstagramPlatform;

  /// No description provided for @aboutInstagramActionLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get aboutInstagramActionLabel;

  /// No description provided for @aboutInstagramDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow us for news, announcements, behind-the-scenes updates, and community content.'**
  String get aboutInstagramDescription;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Seg-Dude. All rights reserved.'**
  String get aboutCopyright;

  /// No description provided for @aboutBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get aboutBackToHome;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @groupsAreAssignedToAClass.
  ///
  /// In en, this message translates to:
  /// **'groups are assigned to a class'**
  String get groupsAreAssignedToAClass;

  /// No description provided for @groupsSplitClsIntoGroups.
  ///
  /// In en, this message translates to:
  /// **'Split Class Into Groups'**
  String get groupsSplitClsIntoGroups;

  /// No description provided for @groupsSelectClassToSplit.
  ///
  /// In en, this message translates to:
  /// **'Please select a class to split, click on the add button.'**
  String get groupsSelectClassToSplit;

  /// No description provided for @groupsAddSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Please Create subjects first to be able to split Classes'**
  String get groupsAddSubjectFirst;

  /// No description provided for @groupsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Group'**
  String get groupsAdd;

  /// No description provided for @groupsApplyToOthers.
  ///
  /// In en, this message translates to:
  /// **'Apply To Other Classes'**
  String get groupsApplyToOthers;

  /// No description provided for @groupsApplyToOthersDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to apply the same constraint to all classes in the same level?'**
  String get groupsApplyToOthersDesc;

  /// No description provided for @groupsNotConf.
  ///
  /// In en, this message translates to:
  /// **'No Groups configured yet'**
  String get groupsNotConf;

  /// No description provided for @groupsMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge Classes'**
  String get groupsMerge;

  /// No description provided for @groupsMergeClasses.
  ///
  /// In en, this message translates to:
  /// **'Merge classes into one group'**
  String get groupsMergeClasses;

  /// No description provided for @groupsSelectClassesToMerge.
  ///
  /// In en, this message translates to:
  /// **'Select at least two classes from this level.'**
  String get groupsSelectClassesToMerge;

  /// No description provided for @groupsMergeWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Split groups found'**
  String get groupsMergeWarningTitle;

  /// No description provided for @groupsMergeWarning.
  ///
  /// In en, this message translates to:
  /// **'Some selected classes have split groups for this subject. Merging them will remove those split-group constraints. Continue?'**
  String get groupsMergeWarning;

  /// No description provided for @groupsSelectTeacherFirstToMerge.
  ///
  /// In en, this message translates to:
  /// **'Select a teacher first'**
  String get groupsSelectTeacherFirstToMerge;

  /// No description provided for @groupsNoClassesForTeacherSubject.
  ///
  /// In en, this message translates to:
  /// **'No eligible classes for this teacher and subject'**
  String get groupsNoClassesForTeacherSubject;

  /// No description provided for @groupsClassesSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} classes selected'**
  String groupsClassesSelectedCount(int count);

  /// No description provided for @groupsMergeSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get groupsMergeSummary;

  /// No description provided for @groupsMergeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Classes merged successfully'**
  String get groupsMergeSuccessMessage;

  /// No description provided for @groupsSelectSubjectToMerge.
  ///
  /// In en, this message translates to:
  /// **'Choose the subject for this merge'**
  String get groupsSelectSubjectToMerge;

  /// No description provided for @groupsSelectTeacherToMerge.
  ///
  /// In en, this message translates to:
  /// **'Select the teacher responsible for this subject'**
  String get groupsSelectTeacherToMerge;

  /// No description provided for @groupsNoTeacherAssignedForSubject.
  ///
  /// In en, this message translates to:
  /// **'No teacher is assigned for this subject — you can still merge its classes'**
  String get groupsNoTeacherAssignedForSubject;

  /// No description provided for @groupsNoTeacherAssignedShort.
  ///
  /// In en, this message translates to:
  /// **'No teacher assigned'**
  String get groupsNoTeacherAssignedShort;

  /// No description provided for @groupsNoQualifiedTeacherMergeBlocked.
  ///
  /// In en, this message translates to:
  /// **'No teacher is qualified for this subject at this level — merging is not available'**
  String get groupsNoQualifiedTeacherMergeBlocked;

  /// No description provided for @deleteSubjectWarning.
  ///
  /// In en, this message translates to:
  /// **'Teachers and groups associated with this subjcet will also be deleted.'**
  String get deleteSubjectWarning;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'Id'**
  String get id;

  /// No description provided for @grouping.
  ///
  /// In en, this message translates to:
  /// **'Grouping'**
  String get grouping;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noMatchingRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No matching records found'**
  String get noMatchingRecordsFound;

  /// No description provided for @supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get supervisor;

  /// No description provided for @loadFromFile.
  ///
  /// In en, this message translates to:
  /// **'Load from file'**
  String get loadFromFile;

  /// No description provided for @noSavedScheduleFound.
  ///
  /// In en, this message translates to:
  /// **'No saved schedule found'**
  String get noSavedScheduleFound;

  /// No description provided for @clickToCreateNewSchedule.
  ///
  /// In en, this message translates to:
  /// **'Click to create a new schedule'**
  String get clickToCreateNewSchedule;

  /// No description provided for @creationOptions.
  ///
  /// In en, this message translates to:
  /// **'Options for creating a new schedule'**
  String get creationOptions;

  /// No description provided for @chooseHowCreate.
  ///
  /// In en, this message translates to:
  /// **'Choose how to create a new schedule.'**
  String get chooseHowCreate;

  /// No description provided for @collapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get collapse;

  /// No description provided for @noGaps.
  ///
  /// In en, this message translates to:
  /// **'Generate a schedule with no gaps (Student-biased)'**
  String get noGaps;

  /// No description provided for @teacherBias.
  ///
  /// In en, this message translates to:
  /// **'Generate a schedule with groups of teachers (Teacher-biased)'**
  String get teacherBias;

  /// No description provided for @studFirst.
  ///
  /// In en, this message translates to:
  /// **'Student first'**
  String get studFirst;

  /// No description provided for @teacherFirst.
  ///
  /// In en, this message translates to:
  /// **'Teacher first'**
  String get teacherFirst;

  /// No description provided for @ifNoneSelected.
  ///
  /// In en, this message translates to:
  /// **'(If no class is selected, then all classes)'**
  String get ifNoneSelected;

  /// No description provided for @ifSubjetMultiTeachers.
  ///
  /// In en, this message translates to:
  /// **'If the subject has more than one teacher, the system of periods and groups is applied.'**
  String get ifSubjetMultiTeachers;

  /// No description provided for @teachersCoexist.
  ///
  /// In en, this message translates to:
  /// **'Teachers of a particular subject may be present in school during the same period.'**
  String get teachersCoexist;

  /// No description provided for @licenseWarning.
  ///
  /// In en, this message translates to:
  /// **'Data may be incorrect without premium license'**
  String get licenseWarning;

  /// No description provided for @licenseWarningDesc.
  ///
  /// In en, this message translates to:
  /// **'Please get a premium license to get correct data.'**
  String get licenseWarningDesc;

  /// No description provided for @schoolSeason.
  ///
  /// In en, this message translates to:
  /// **'School Season'**
  String get schoolSeason;

  /// No description provided for @subjRequireRooms.
  ///
  /// In en, this message translates to:
  /// **'Subject requires room'**
  String get subjRequireRooms;

  /// No description provided for @freeResourcesTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Free Resources'**
  String get freeResourcesTabTitle;

  /// No description provided for @freeResourcesForLevel.
  ///
  /// In en, this message translates to:
  /// **'Free Resources - Level {level}'**
  String freeResourcesForLevel(String level);

  /// No description provided for @freeClassesLabel.
  ///
  /// In en, this message translates to:
  /// **'Free Classes'**
  String get freeClassesLabel;

  /// No description provided for @freeQualifiedTeachersLabel.
  ///
  /// In en, this message translates to:
  /// **'Available Teachers'**
  String get freeQualifiedTeachersLabel;

  /// No description provided for @freeRoomsLabel.
  ///
  /// In en, this message translates to:
  /// **'Free Rooms'**
  String get freeRoomsLabel;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noneLabel;

  /// No description provided for @noFreeSlotsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No free slots this day'**
  String get noFreeSlotsThisDay;

  /// No description provided for @noFreeSlotsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No free slots available'**
  String get noFreeSlotsAvailable;

  /// No description provided for @freeForAllClasses.
  ///
  /// In en, this message translates to:
  /// **'All levels free'**
  String get freeForAllClasses;

  /// No description provided for @freeForLevelClasses.
  ///
  /// In en, this message translates to:
  /// **'Whole level free'**
  String get freeForLevelClasses;

  /// No description provided for @freeForSomeClasses.
  ///
  /// In en, this message translates to:
  /// **'Some classes free'**
  String get freeForSomeClasses;

  /// No description provided for @levelNumberFallback.
  ///
  /// In en, this message translates to:
  /// **'Level {id}'**
  String levelNumberFallback(String id);

  /// Hint shown near the availability legend and as a tooltip on level chips, indicating the chip can be tapped to view available teachers and rooms.
  ///
  /// In en, this message translates to:
  /// **'Tap a level to see available teachers & rooms'**
  String get tapLevelForDetailsHint;

  /// No description provided for @forcedSubjectInAllowedRooms.
  ///
  /// In en, this message translates to:
  /// **'{subjectName} is forced to a specific room, but it appears in the allowed subjects of {roomName}. Continue will remove it from the allowed subjects of {roomName}.'**
  String forcedSubjectInAllowedRooms(String subjectName, String roomName);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
