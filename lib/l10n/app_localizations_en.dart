// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lkout';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get error => 'Error';

  @override
  String get welcome => 'Welcome';

  @override
  String get timetable => 'timetable';

  @override
  String get timetableCreate => 'Create timetable';

  @override
  String get timetableResult => 'timetable Result';

  @override
  String get fieldRequired => 'Required';

  @override
  String get mustBePositive => 'Must be ≥ 1';

  @override
  String get idAlreadyUsed => 'ID already in use';

  @override
  String get minTwoChars => 'Min. 2 characters';

  @override
  String get invalidHoursFormat => 'Format: levelId:hours — e.g. 1:6,2:4';

  @override
  String get levelsRequired => 'Enter at least one level — e.g. 1,2';

  @override
  String get invalidFormat => 'Invalid format — e.g. 1,2';

  @override
  String get slotRange => 'Slot must be between 1 and 24';

  @override
  String get slotAlreadyUsed => 'Slot already defined as a break';

  @override
  String get dayRange => 'Day must be between 1 and 7';

  @override
  String get minTwo => 'Must be ≥ 2';

  @override
  String get selectASubject => 'Select a subject';

  @override
  String get searchTeacherHint => 'Search teacher...';

  @override
  String get noTeachersForSubject => 'No teachers for this subject';

  @override
  String get addRooms => 'Add Rooms';

  @override
  String get addSubject => 'Add Subject';

  @override
  String get editTeacher => 'Edit Teacher';

  @override
  String teacherUpdatedSuccessfully(String name) {
    return '$name updated successfully';
  }

  @override
  String get noTeacherScheduleAvailable => 'No teacher schedule available';

  @override
  String teacherNumberFallback(String id) {
    return 'Teacher $id';
  }

  @override
  String dayNumberFallback(String id) {
    return 'Day $id';
  }

  @override
  String subjectNumberFallback(String id) {
    return 'Subject $id';
  }

  @override
  String classNumberFallback(String id) {
    return 'Class $id';
  }

  @override
  String roomNumberFallback(String id) {
    return 'Room $id';
  }

  @override
  String get editSubject => 'Edit Subject';

  @override
  String get editRoom => 'Edit Room';

  @override
  String get save => 'Save';

  @override
  String get addTeacher => 'Add Teacher';

  @override
  String get addABreakHour => 'Add a break hour';

  @override
  String get addEdit => 'Add/Edit';

  @override
  String get allDataCleared => 'All data cleared!';

  @override
  String get awesome => 'Awesome';

  @override
  String get cancel => 'Cancel';

  @override
  String get chooseLevel => 'Choose level...';

  @override
  String get clearOverrides => 'Clear Overrides';

  @override
  String get confirmPay => 'Confirm & Pay';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get continueBtn => 'Continue';

  @override
  String get createSchedule => 'Create Schedule';

  @override
  String get createSubject => 'Create Subject';

  @override
  String get enterPhoneNumber => 'Enter Phone Number';

  @override
  String get errorMsg => 'Error';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get generate => 'Generate';

  @override
  String get info => 'Info';

  @override
  String get insufficientTeachers => 'Insufficient Teachers';

  @override
  String get language => 'Language';

  @override
  String get manualOverridesPlanner => 'Manual Overrides Planner';

  @override
  String get minutesMustBeBetween1And59 => 'Minutes must be between 1 and 59!';

  @override
  String get noRoomsConfiguredYet => 'No rooms configured yet.';

  @override
  String get noSubjectsAddedYet => 'No subjects added yet.';

  @override
  String get noTeachersAssignedYet =>
      'No teachers assigned yet. Use Menu Above to Disable including teachers';

  @override
  String get ok => 'OK';

  @override
  String get confirmQuestion => 'Are you sure?';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get pinSlot => 'Pin Slot';

  @override
  String get pleaseAddRooms => 'Please add rooms';

  @override
  String get pleaseAddSubjects => 'Please add subjects';

  @override
  String get pleaseAddTeachers =>
      'Please add teachers OR disable including teachers in payload';

  @override
  String get includeTeachersInPayload => 'Include real teacher list';

  @override
  String get includeTeachersInPayloadHint =>
      'When disabled, the generator sends placeholder teachers to the backend while still allowing schedule creation.';

  @override
  String get pleaseSelectAClassFirst => 'Please select a class first!';

  @override
  String get pleaseSelectAtLeastOneWorkingD =>
      'Please select at least one working day';

  @override
  String get scheduleResult => 'Schedule Result';

  @override
  String get scheduleSkeleton => 'Schedule Skeleton';

  @override
  String get scheduleDataNotFound => 'Schedule data not found.';

  @override
  String get send => 'Send';

  @override
  String get timingConstraints => 'Timing Constraints';

  @override
  String get tryAnyway => 'Try Anyway';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get yourPremiumFeaturesHaveBeenUnl =>
      'Your premium features have been unlocked.';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogoutTitle => 'Confirm Logout';

  @override
  String get confirmLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get alreadyHave => 'Already have an account?';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get profile => 'Profile';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get firstName => 'First Name';

  @override
  String get institution => 'Institution';

  @override
  String get lastName => 'Last Name';

  @override
  String get phone => 'Phone';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address to receive a link to reset your password.';

  @override
  String get emailNotConfirmedError => 'Email not confirmed.';

  @override
  String get pleaseConfirmEmail => 'Please confirm your email';

  @override
  String get emailWillBeSentTo => 'Email will be sent to : ';

  @override
  String get errorPrefix => 'Error:';

  @override
  String get signInWelcome => 'Sign In Welcome';

  @override
  String get pleaseEnterEmail => 'Please enter an email';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get pleaseEnterPassword => 'Please enter a password';

  @override
  String get shortPassword => 'Password must be at least 6 characters';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get pleaseSelectRole => 'Please select a role';

  @override
  String get welcomesegtotimetable => 'Welcome to seg-timetable';

  @override
  String get noMorePlaceAnimation => 'No More Place For Animation';

  @override
  String get emptyFirstName => 'emptyFirstName';

  @override
  String get emptyLastName => 'emptyLastName';

  @override
  String get fillAllFields => 'fillAllFields';

  @override
  String get passwordNotMatch => 'passwordNotMatch';

  @override
  String get roleDirector => 'Director';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleLabel => 'role';

  @override
  String get signInLabel => 'sign_in';

  @override
  String get optional => 'Optional';

  @override
  String get guide => 'Guide';

  @override
  String get subject => 'Subject';

  @override
  String get teacher => 'Teacher';

  @override
  String get teachers => 'Teachers';

  @override
  String get room => 'Room';

  @override
  String get rooms => 'Rooms';

  @override
  String get restricted => 'restricted';

  @override
  String get consecutive => 'consecutive';

  @override
  String get levels => 'Levels';

  @override
  String get subjects => 'Subjects';

  @override
  String get weeklyHours => 'Weekly Hours';

  @override
  String get classes => 'Classes';

  @override
  String get hours => 'Hours';

  @override
  String get filterTeachersBySubject => 'Filter teachers by subject';

  @override
  String get allSubjects => 'All subjects';

  @override
  String get searchForATeacher => 'Search for a teacher';

  @override
  String get selectATeacherToViewSchedule =>
      'Select a teacher to view their schedule.';

  @override
  String roomAddedSuccessfully(String name) {
    return '\"$name\" added successfully';
  }

  @override
  String roomRemoved(String name) {
    return '\"$name\" removed';
  }

  @override
  String roomUpdatedSuccessfully(String name) {
    return '\"$name\" updated successfully';
  }

  @override
  String teacherAddedSuccessfully(String name) {
    return '$name added successfully';
  }

  @override
  String teacherRemoved(String name) {
    return '$name removed';
  }

  @override
  String nLevelsSelected(int count) {
    return '$count level(s) selected';
  }

  @override
  String nSubjectsSelected(int count) {
    return '$count subject(s) selected';
  }

  @override
  String capacityValue(int value) {
    return 'Capacity: $value';
  }

  @override
  String maxHoursPerWeekValue(int value) {
    return 'max ${value}h/w';
  }

  @override
  String classesInLevel(String level) {
    return 'Classes in $level';
  }

  @override
  String templatePlannerTitle(String className) {
    return 'Template Planner: $className';
  }

  @override
  String pinLessonForClass(String className) {
    return 'Pin Lesson for $className';
  }

  @override
  String dayAndSlot(String day, int slot) {
    return '$day, Slot $slot';
  }

  @override
  String slotNumber(int number) {
    return 'Slot $number';
  }

  @override
  String nPinned(int count) {
    return '$count pinned';
  }

  @override
  String get sectionBasicInformation => 'BASIC INFORMATION';

  @override
  String get sectionRestrictionsOptional => 'RESTRICTIONS  (OPTIONAL)';

  @override
  String get sectionConstraints => 'CONSTRAINTS';

  @override
  String get cardRoomName => 'ROOM NAME';

  @override
  String get cardCapacityOptional => 'CAPACITY  (OPTIONAL)';

  @override
  String get cardAllowedLevels => 'ALLOWED LEVELS';

  @override
  String get cardAllowedSubjects => 'ALLOWED SUBJECTS';

  @override
  String get cardUsedOnlyFor => 'USED ONLY FOR';

  @override
  String get cardTeacherName => 'TEACHER NAME';

  @override
  String get cardSubject => 'SUBJECT';

  @override
  String get cardQualifiedLevels => 'QUALIFIED LEVELS';

  @override
  String get cardMaxHoursWeekOptional => 'MAX HOURS / WEEK  (OPTIONAL)';

  @override
  String get cardConsecutiveHours => 'CONSECUTIVE HOURS';

  @override
  String get tooltipRoomName =>
      'A unique name that identifies this room. Can be a number, label, or description.';

  @override
  String get tooltipCapacity =>
      'Maximum students this room can hold. Scheduler avoids overcrowding. Default is 40.';

  @override
  String get tooltipAllowedLevels =>
      'Leave empty to allow any level. Select specific levels to reserve this room for them.';

  @override
  String get tooltipAllowedSubjects =>
      'Leave empty to allow any subject. Select subjects to restrict this room (e.g. a lab for Chemistry only).';

  @override
  String get tooltipUsedOnlyFor =>
      'Select a subject to make it mandatory for this room (e.g. a lab for Chemistry only).';

  @override
  String get tooltipTeacherName =>
      'Must be unique. Used to identify this teacher across the schedule.';

  @override
  String get tooltipTeacherSubject =>
      'Each teacher is assigned to one subject. The scheduler matches teachers to classes using this.';

  @override
  String get tooltipQualifiedLevels =>
      'School grades or year groups this teacher is allowed to teach. Select all that apply.';

  @override
  String get tooltipMaxHoursWeek =>
      'Prevents assigning more than this number of hours to this teacher in a single week.';

  @override
  String get tooltipConsecutiveHours =>
      'When enabled, the scheduler tries to group this teacher\'s sessions into a continuous block.';

  @override
  String get hintEnterRoomName => 'Enter room name';

  @override
  String get hintCapacity => 'e.g. 30';

  @override
  String get hintEnterTeacherName => 'Enter teacher name';

  @override
  String get hintSelectSubject => 'Select a subject';

  @override
  String get hintMaxHours => 'e.g. 20';

  @override
  String get capacityDescription =>
      'Maximum number of students. Leave empty to use the default (40).';

  @override
  String get allowedLevelsDescription =>
      'Only Selected Levels Allowed. Leave empty to allow any level.';

  @override
  String get allowedSubjectsDescription =>
      'Leave empty to allow all subjects. Select subjects to restrict this room.';

  @override
  String get usedOnlyForDescription =>
      'Subject forced to use this room only (e.g. a lab for Chemistry only).';

  @override
  String get qualifiedLevelsDescription =>
      'Select every level this teacher is qualified to teach.';

  @override
  String get maxHoursWeekDescription =>
      'Leave empty for no weekly limit. Useful for part-time teachers.';

  @override
  String get requireConsecutiveHours => 'Require consecutive hours';

  @override
  String get consecutiveHoursDescription =>
      'Teacher\'s classes will be scheduled back-to-back.';

  @override
  String get validationRoomNameRequired => 'Room name is required';

  @override
  String get validationNameMinTwoChars => 'Name must be at least 2 characters';

  @override
  String get validationRoomNameAlreadyExists =>
      'A room with this name already exists';

  @override
  String get validationMustBeNumberGteOne => 'Must be a number ≥ 1';

  @override
  String get validationTeacherNameRequired => 'Teacher name is required';

  @override
  String get validationTeacherNameAlreadyExists =>
      'A teacher with this name already exists';

  @override
  String get validationSelectSubjectOrCreate =>
      'Please select a subject or create one';

  @override
  String get validationSelectAtLeastOneLevel => 'Select at least one level';

  @override
  String get validationSelectSubject => 'Please select a subject';

  @override
  String get validationSelectTeacher => 'Please select a teacher';

  @override
  String get validationSelectRoom => 'Please select a room';

  @override
  String get noLevelsDefinedYet => 'No levels defined yet.';

  @override
  String get noSubjectsDefinedYet => 'No subjects defined yet.';

  @override
  String get noRoomsAddedYet => 'No rooms added yet';

  @override
  String get noRoomsAddedYetSubtitle =>
      'Fill the form or use Generate to add rooms';

  @override
  String get noTeachersAddedYet => 'No teachers added yet';

  @override
  String get noTeachersAddedYetSubtitle =>
      'Fill in the form and press Add Teacher';

  @override
  String get unknownSubject => 'Unknown Subject';

  @override
  String get unknownTeacher => 'Unknown Teacher';

  @override
  String get unknownRoom => 'Unknown Room';

  @override
  String get roomsAdded => 'Rooms Added';

  @override
  String get teachersAdded => 'Teachers Added';

  @override
  String get removeRoom => 'Remove room';

  @override
  String get removeTeacher => 'Remove teacher';

  @override
  String get swipeLeftToDeleteRoom => 'Swipe left to delete a room';

  @override
  String get addRoom => 'Add Room';

  @override
  String get createNewSubject => 'Create new subject';

  @override
  String get generateRooms => 'Generate Rooms';

  @override
  String get generateRoomsDescription =>
      'Quickly add multiple rooms with a numbered name pattern.';

  @override
  String get numberOfRooms => 'Number of rooms';

  @override
  String get numberOfRoomsHint => 'e.g. 10';

  @override
  String get namePatternLabel => 'Name pattern  (# → number)';

  @override
  String get namePatternHint => 'e.g. Room # → Room 1, Room 2…';

  @override
  String get helpSheetRoomsTitle => 'Add Rooms — Guide';

  @override
  String get helpSheetTeachersTitle => 'Add Teacher — Guide';

  @override
  String get helpSheetSubtitle => 'What to enter in each field';

  @override
  String get helpEntryRoomNameTitle => 'Room Name';

  @override
  String get helpEntryRoomNameBody =>
      'A unique name to identify this room in the schedule.\n\n• At least 2 characters, must be unique\n• Examples: \"Room 101\", \"Science Lab\", \"Computer Room\", \"Library Hall\"';

  @override
  String get helpEntryCapacityTitle => 'Capacity';

  @override
  String get helpEntryCapacityBody =>
      'The maximum number of students this room can hold at once.\n\n• Leave empty to use the default capacity (40 students)\n• The scheduler uses this to prevent overcrowding\n• Example: Enter \"25\" if the lab only has 25 seats';

  @override
  String get helpEntryAllowedLevelsTitle => 'Allowed Levels';

  @override
  String get helpEntryAllowedLevelsBody =>
      'Restrict this room so that only specific school levels can use it.\n\n• Leave all unselected to allow any level\n• Select one or more levels to reserve this room for specific grades\n• Example: A \"Grade 5 Classroom\" reserved only for Grade 5 students';

  @override
  String get helpEntryAllowedSubjectsTitle => 'Allowed Subjects';

  @override
  String get helpEntryAllowedSubjectsBody =>
      'Restrict this room so only specific subjects can be taught in it.\n\n• Leave all unselected to allow any subject\n• Select subjects if the room has special equipment for certain classes\n• Example: A \"Chemistry Lab\" should only be used for Chemistry';

  @override
  String get helpEntryGenerateRoomsTitle => 'Generate Rooms (Quick Action)';

  @override
  String get helpEntryGenerateRoomsBody =>
      'Use the \"Generate\" button in the toolbar to create many rooms at once.\n\n• Enter how many rooms you need\n• Use # as a placeholder for the room number in the name\n• Example: \"Room #\" with count 5 → creates \"Room 1\" through \"Room 5\"\n• Generated rooms use default capacity (40) with no restrictions';

  @override
  String get helpEntryDeletingRoomTitle => 'Deleting a Room';

  @override
  String get helpEntryDeletingRoomBody =>
      'You can remove a room from the list after adding it.\n\n• Swipe left on any room tile to delete it\n• Or hover over the tile and tap the 🗑 icon on the right';

  @override
  String get helpEntryTeacherNameTitle => 'Teacher Name';

  @override
  String get helpEntryTeacherNameBody =>
      'The full name of the teacher to add to the schedule.\n\n• At least 2 characters, must be unique\n• Examples: \"Sarah Ibrahim\", \"Mr. Ahmed\", \"Dr. Leila\"';

  @override
  String get helpEntryTeacherSubjectTitle => 'Subject';

  @override
  String get helpEntryTeacherSubjectBody =>
      'The subject this teacher is qualified to teach.\n\n• Each teacher is linked to exactly one subject\n• The scheduler uses this to assign the right teacher to each class\n• If the subject is missing, tap \"Create new subject\" to add it first';

  @override
  String get helpEntryQualifiedLevelsTitle => 'Qualified Levels';

  @override
  String get helpEntryQualifiedLevelsBody =>
      'The school levels (grades/year groups) this teacher can teach.\n\n• Select at least one level\n• Choose all levels that apply — a teacher can cover multiple levels\n• Example: Select \"Grade 4\" and \"Grade 5\" if the teacher can handle both';

  @override
  String get helpEntryMaxHoursTitle => 'Max Hours / Week';

  @override
  String get helpEntryMaxHoursBody =>
      'The maximum teaching hours this teacher can have in one week.\n\n• Leave empty for no limit\n• Useful for part-time teachers or to avoid overloading staff\n• Example: Enter \"18\" to cap the teacher at 18 hours/week';

  @override
  String get helpEntryConsecutiveHoursTitle => 'Consecutive Hours';

  @override
  String get helpEntryConsecutiveHoursBody =>
      'Controls whether this teacher\'s classes should be scheduled back-to-back.\n\n• ✅ Checked — Scheduler groups this teacher\'s lessons in a continuous block\n• ☐ Unchecked — Lessons can be spread freely through the day\n• Useful for teachers who prefer teaching all classes in one session';

  @override
  String get createSubjectEmptyHint =>
      'Select a level and press the + button (Ctrl+A/Cmd+A) to add subjects\nif subject is taught to this level increase the weekly hours else leave it at 0\nread documentation for more info';

  @override
  String get addSubjectTooltip => 'Add Subject (Ctrl+A/Cmd+A)';

  @override
  String get levelSelected => 'Selected ✓';

  @override
  String get levelTapToSelect => 'Tap to select';

  @override
  String get daySlotHeader => 'Day / Slot';

  @override
  String get breakTime => 'Break Time';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get selectLevelToViewClasses => 'Select a level to view classes.';

  @override
  String get selectClassToStartPinning =>
      'Select a class from the sidebar to start pinning slots.';

  @override
  String get pleaseAddLevelsFirst =>
      'Please add levels first on the main page.';

  @override
  String get pleaseCompleteWorkingDaysConfig =>
      'Please complete the working days & timeslots configuration on the first page first.';

  @override
  String get templatePlannerSubtitle =>
      'Force specific subjects, teachers, and rooms. Pinned classes are strictly respected by the generator.';

  @override
  String get clearedOverridesForClass => 'Cleared overrides for this class.';

  @override
  String get selectSubjectFirst => 'Select a subject first';

  @override
  String get noQualifiedTeachersForLevelSubject =>
      'No qualified teachers for this level & subject';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get whileGeneratingTitle =>
      'Please wait while the schedule is being generated...';

  @override
  String get whileGeneratingDescription =>
      'Once the schedule is generated, you will be redirected to the schedule details page.\nThe solver (algorithm) will be running in the server trying all possible combinations to find the OPTIMAL solution. \nA lack of resources will lead to FEASIBLE not OPTIMAL solutions or unfeasible at all.';

  @override
  String get whileGeneratingWarning =>
      'If it takes too long, that means the solver is going to fail';

  @override
  String get generatingStatusInitializing =>
      'Initializing schedule generation...';

  @override
  String get generatingStatusEvaluating => 'Evaluating constraints...';

  @override
  String get generatingStatusSearching =>
      'Searching for the optimal schedule...';

  @override
  String get generatingStatusOptimizing => 'Optimizing timetable...';

  @override
  String get generatingStatusFinalizing => 'Finalizing schedule...';

  @override
  String estimatedTime(String duration) {
    return 'Estimated time: $duration';
  }

  @override
  String estimatedTimeMinSec(int minutes, int seconds) {
    return '$minutes min $seconds sec';
  }

  @override
  String estimatedTimeSec(int seconds) {
    return '$seconds sec';
  }

  @override
  String get homeHeroTitle => 'Build Perfect\nClass Schedules\nin Minutes';

  @override
  String get homeHeroSubtitle =>
      'Stop wrestling with spreadsheets. seg-timetable automatically assigns teachers, rooms and time-slots so every class gets the schedule it deserves — conflict-free.';

  @override
  String get homeInstitutionNotice =>
      'Mainly created for schools, but can be used by any institution that needs timetables.';

  @override
  String get homeCtaButton => 'Create Your Schedule';

  @override
  String get homeSocialProof => 'Free to get started · No account required';

  @override
  String get homeWeeklySchedulePreview => 'Weekly Schedule Preview';

  @override
  String get homeFeaturesTitle => 'Everything you need to schedule smarter';

  @override
  String get homeFeaturesSubtitle =>
      'Powerful features packed into a clean, intuitive interface.';

  @override
  String get homeFeatureInstantGenerationTitle => 'Instant Generation';

  @override
  String get homeFeatureInstantGenerationDesc =>
      'Our algorithm processes your constraints and produces a complete, conflict-free timetable in seconds.';

  @override
  String get homeFeatureTeacherRoomTitle => 'Teacher & Room Management';

  @override
  String get homeFeatureTeacherRoomDesc =>
      'Add teachers, define subjects and assign rooms. The scheduler respects availability and capacity.';

  @override
  String get homeFeatureManualOverridesTitle => 'Manual Overrides';

  @override
  String get homeFeatureManualOverridesDesc =>
      'Need to pin a specific slot? Use the manual override planner to lock assignments while keeping the rest optimised.';

  @override
  String get homeFeatureExportPdfTitle => 'Export to PDF';

  @override
  String get homeFeatureExportPdfDesc =>
      'Print or share your schedule as a professional PDF with one click — ready for notice boards or staff emails.';

  @override
  String get homeHowItWorksChip => 'HOW IT WORKS';

  @override
  String get homeHowItWorksTitle =>
      'From blank page to published schedule\nin four simple steps';

  @override
  String get homeStep1Title => 'Set Timing Constraints';

  @override
  String get homeStep1Desc =>
      'Choose your working days, define start and end hours, and mark any break periods.';

  @override
  String get homeStep2Title => 'Add Teachers, Subjects & Rooms';

  @override
  String get homeStep2Desc =>
      'Input all the people and resources the scheduler needs to work with.';

  @override
  String get homeStep3Title => 'Generate';

  @override
  String get homeStep3Desc =>
      'Hit generate and watch the algorithm build a perfectly balanced schedule for every class.';

  @override
  String get homeStep4Title => 'Review & Export';

  @override
  String get homeStep4Desc =>
      'Inspect the result, apply any manual overrides, then export a polished PDF.';

  @override
  String get homeStartForFree => 'Start for free';

  @override
  String get homeBottomCtaTitle => 'Ready to build your first schedule?';

  @override
  String get homeBottomCtaSubtitle =>
      'It only takes a few minutes to configure your school and let the algorithm do the heavy lifting.';

  @override
  String get homeBottomCtaButton => 'Create Your Schedule Now';

  @override
  String get homeCopyright => 'Lkout © 2026';

  @override
  String get startFreshTitle => 'Start Fresh?';

  @override
  String get startFreshContent =>
      'This will delete all saved data including teachers, subjects, rooms, and schedule settings. Are you sure?';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get lastGenerated => 'Last Generated';

  @override
  String get selectWorkingDays => 'Select Working Days';

  @override
  String get pleaseSelectOneDayOrderMatters =>
      'Please select at least one day — ORDER MATTERS:';

  @override
  String get workingHoursTitle => 'Working Hours  (e.g. 8 = 08:00)';

  @override
  String get workingHoursHint =>
      'Enter the first and last hour of the school day.';

  @override
  String get startHourRequired => 'Start hour is required';

  @override
  String get enterWholeNumber => 'Enter a whole number';

  @override
  String get mustBeBetween1And22 => 'Must be between 1 and 22';

  @override
  String get startHourLabel => 'From';

  @override
  String get endHourRequired => 'End hour is required';

  @override
  String get cannotExceed23 => 'Cannot exceed 23';

  @override
  String get mustBeAfterStartHour => 'Must be after start hour';

  @override
  String get endHourLabel => 'To';

  @override
  String get timeslotsFormula => 'Timeslots = end hour − start hour';

  @override
  String get maxHoursPerStudentPerDay => 'Max Hours per Student per Day';

  @override
  String get maxHoursPerDayHint =>
      'A class cannot be scheduled for more hours than this value in a single day.';

  @override
  String get pleaseSelectValidValue =>
      'Please select a valid value (1 or more)';

  @override
  String get breakHoursTitle => 'Break Hours';

  @override
  String get breakHoursHint => 'e.g. Lunch 12:00–14:00 → select 12 and 13.';

  @override
  String get pleaseSelectStartAndEndHoursFirst =>
      'Please select start and end hours first';

  @override
  String get breakHourMustBeAfterStartHour =>
      'Break hour must be after start hour';

  @override
  String get breakHourMustBeBeforeEndHour =>
      'Break hour must be before end hour';

  @override
  String get breakSlots => 'Break slots:';

  @override
  String get noBreakHoursSelected => 'No break hours selected';

  @override
  String get editSpecificDaySlots => 'Edit Specific Day Slots';

  @override
  String get clickDayToManageSlots => 'Click a day to manage its active slots.';

  @override
  String get noDaysSelected => 'No days selected';

  @override
  String get scheduleSummary => 'Schedule Summary';

  @override
  String get summaryDaysPerWeek => 'Days per week';

  @override
  String get summaryTimeslotsPerDay => 'Timeslots / day';

  @override
  String get summaryMaxHoursPerDay => 'Max hours / day';

  @override
  String get summaryBreakHours => 'Break hours';

  @override
  String get summarySelectedDays => 'Selected days';

  @override
  String get nextLabel => 'Next';

  @override
  String get nextStageTooltip => 'Next stage';

  @override
  String get startByAddingLevels => 'Start by adding levels';

  @override
  String get addLevelsInstructions =>
      'First add levels, then subjects, then rooms, then manual overrides';

  @override
  String get addLevels => 'Add levels';

  @override
  String get levelsColumnHeader => 'Levels';

  @override
  String get addLevel => 'Add Level';

  @override
  String get removeLevelTooltip => 'Remove level';

  @override
  String get selectLevelToViewDetailsHeader => 'Select a level to view details';

  @override
  String detailsForLevel(String level) {
    return 'Details for $level';
  }

  @override
  String get subjectsTaught => 'Subjects Taught';

  @override
  String get assignedTeachers => 'Assigned Teachers';

  @override
  String get availableRooms => 'Available Rooms';

  @override
  String get manualOverridesSection => 'Manual Overrides';

  @override
  String get noManualOverridesForLevel =>
      'No manual overrides configured for this level.';

  @override
  String activeOverrideConstraints(int count) {
    return '$count active override constraint(s) pinned for classes in this level.';
  }

  @override
  String get pleaseSelectLevelFromLeft =>
      'Please select a level from the left to view and manage\nits subjects, teachers, and rooms.';

  @override
  String get allRoomsForcedNoFreeRooms =>
      'All rooms are forced for specific subjects, leaving no free rooms for the remaining subjects.';

  @override
  String get hasNoTeacher => 'has no teacher';

  @override
  String needHoursNoQualifiedTeacher(int hours, String subject, String level) {
    return '$level needs $hours hours of \"$subject\" but no teacher is qualified, add teacher to level $level';
  }

  @override
  String notEnoughTeachersContent(
    String subject,
    int required,
    int available,
    int needed,
  ) {
    return 'Not enough teachers for $subject!\n\n• Required: $required hours\n• Available capacity: $available hours\n\nConsider adding ~$needed more teacher(s).';
  }

  @override
  String get insufficientRoomsTitle => 'Insufficient Rooms';

  @override
  String get roomCapacityMayBeInsufficient =>
      'Room capacity may be insufficient';

  @override
  String get currentRooms => 'Current rooms:';

  @override
  String get predictedNeeded => 'Predicted needed:';

  @override
  String get totalClassHoursWeek => 'Total class-hours/week:';

  @override
  String get ratioPerRoom => 'Ratio per room:';

  @override
  String get schedulerMayFail =>
      'The scheduler may fail to find a solution. Consider adding more rooms.';

  @override
  String classesCount(int count) {
    return 'Classes: $count';
  }

  @override
  String get pdfLockedSlot => 'lock';

  @override
  String get pdfDocumentName => 'My_Document';

  @override
  String get settings => 'Settings';

  @override
  String get print => 'Print';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noScheduleDataGoHome =>
      'No schedule data found. Returning home...';

  @override
  String get selectAClass => 'Select a class';

  @override
  String get selectClassToViewSchedule =>
      'Select a class from the list to view its schedule.';

  @override
  String get scheduleGenerationFailed => 'Schedule generation failed.';

  @override
  String get generalCategory => 'General';

  @override
  String get noDetailsProvided => 'No details provided.';

  @override
  String get noFurtherDiagnostics => 'No further diagnostics available.';

  @override
  String solutionHint(String hint) {
    return 'Hint: $hint';
  }

  @override
  String clsCount(int count) {
    return '$count class(es)';
  }

  @override
  String get saveExit => 'Save & Exit';

  @override
  String get clickToAddHeaderImage => 'Click to add header image';

  @override
  String get name => 'Name';

  @override
  String get close => 'Close';

  @override
  String get dearUser => 'Dear User';

  @override
  String get paymentWorkInProgress =>
      'Payment integration is currently in progress. Please contact us directly to complete your purchase.';

  @override
  String get paymentIntegrationMessage =>
      'We are currently still working on payment integration.\nWe apologize for the inconvenience. We will be back soon with a better solution. Thank you for your patience.';

  @override
  String get contactEmail => 'Email: abdoullouahd@gmail.com';

  @override
  String get contactPhone => 'Phone: +212628503463';

  @override
  String get thankYouForUnderstanding => 'Thank you for your understanding!';

  @override
  String get amountDisplay => 'Amount: 299 MAD';

  @override
  String feesDisplay(String fees) {
    return 'Fees: $fees MAD';
  }

  @override
  String totalDisplay(String total) {
    return 'Total: $total MAD';
  }

  @override
  String paymentFailed(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get unlockFullPotential => 'Unlock the Full Potential';

  @override
  String get fullAccessDescription =>
      'Get full access to all features and generate unlimited schedules.';

  @override
  String get getFullAccess =>
      'Get full access to your schedule without restrictions.';

  @override
  String get premiumAccess => 'Premium Access';

  @override
  String get perEightMonths => '/ 8 months';

  @override
  String get featureRemoveLockedSlots => 'Remove locked slots';

  @override
  String get featureExportPdf => 'Export to PDF';

  @override
  String get featureAnyDevice => 'Access on any device';

  @override
  String get featureManualOverrides => 'Manual overrides';

  @override
  String get featurePrioritySupport => 'Priority support';

  @override
  String get removeLockedSlots => 'Remove all locked slots';

  @override
  String get exportPdf => 'Export schedule to high-quality PDF';

  @override
  String get anyDevice => 'Get your schedule on any device';

  @override
  String get advancedOverrides => 'Advanced manual overrides';

  @override
  String get prioritySupport => 'Priority customer support';

  @override
  String get upgradeNow => 'Upgrade Now';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String get demoLimitTitle => 'Demo Limit Reached';

  @override
  String get demoLimitContent =>
      'The demo version only supports schedules with fewer than 30 classes. Sign in or upgrade to Premium to generate schedules with 30 or more classes.';

  @override
  String get signInOrUpgrade => 'Sign In / Upgrade';

  @override
  String get segtimetableDescription =>
      'A modern platform for managing school timetables with simplicity and efficiency.';

  @override
  String get featureTimetablesTitle => 'School Timetables';

  @override
  String get featureTimetablesDesc =>
      'Create and manage school timetables easily.';

  @override
  String get featureSecureTitle => 'Secure & Reliable';

  @override
  String get featureSecureDesc =>
      'Your information is protected and safely stored.';

  @override
  String get featureSaveTimeTitle => 'Save Time';

  @override
  String get featureSaveTimeDesc =>
      'Organize schedules faster with a streamlined workflow.';

  @override
  String get featureSimpleTitle => 'Simple Experience';

  @override
  String get featureSimpleDesc =>
      'An intuitive interface designed for everyone.';

  @override
  String get segtimetableQuote =>
      'Organizing timetables, so you can focus on teaching.';

  @override
  String get signInSubtitle => 'Welcome back! Please sign in to your account.';

  @override
  String get signUpSubtitle =>
      'Create your account by filling in the details below.';

  @override
  String get requestTimedOut =>
      'The request took too long. Please check your connection and try again.';

  @override
  String get unexpectedError => 'Something went wrong. Please try again.';

  @override
  String get resetPasswordSuccess =>
      'If an account exists for this email, a reset link has been sent.';

  @override
  String get warning => 'Warning';

  @override
  String get eraseSavedScheduleWarning =>
      'Generating a new schedule will erase the saved one.';

  @override
  String get impossibleToRecreate =>
      'It\'s nearly impossible to generate same schedule twice.';

  @override
  String get sureToContinue => 'Are you sure you want to continue?';

  @override
  String get loadLastCreatedSchedule => 'Load Last Created Schedule';

  @override
  String get pricing => 'Pricing';

  @override
  String get aboutUs => 'About Us';

  @override
  String get exitCreator => 'Exit Creator';

  @override
  String get exitConfirmMessage =>
      'Are you sure you want to exit? Your unsaved changes will be lost.';

  @override
  String get exitBtn => 'Exit';

  @override
  String get hintStartHour => 'e.g. 8';

  @override
  String get hintEndHour => 'e.g. 17';

  @override
  String get validationLevelNameRequired => 'Level name is required';

  @override
  String get validationLevelAlreadyExists => 'This level already exists';

  @override
  String get validationClassesRequired => 'Number of classes is required';

  @override
  String get labelLevelName => 'Level name';

  @override
  String get hintLevelName => 'e.g. Primary 1';

  @override
  String get labelNumberOfClasses => 'Number of classes';

  @override
  String get hintNumberOfClasses => 'e.g. 3';

  @override
  String get validationSubjectNameRequired => 'Subject name is required';

  @override
  String get validationSubjectAlreadyExists => 'Subject already exists';

  @override
  String get hintSubjectName => 'e.g. Mathematics';

  @override
  String get validationNonNegativeNumber => 'Enter a non-negative number';

  @override
  String get validationCommaSeparatedNumbers => 'Enter comma-separated numbers';

  @override
  String get subjectColor => 'Subject color';

  @override
  String get advancedParameters => 'Advanced parameters';

  @override
  String get minimumRestHours => 'Minimum rest hours';

  @override
  String get avoidHours => 'Avoid hours';

  @override
  String get avoidHoursHint => 'Optional, e.g. 1, 3, 5';

  @override
  String get validationRoomAlreadyExists => 'Room already exists';

  @override
  String get hintRoomName => 'e.g. Room 101';

  @override
  String get validationNumberOfRoomsRequired => 'Number of rooms is required';

  @override
  String get titleUpdateMinutes => 'Update Minutes';

  @override
  String get labelMinutes => 'Minutes';

  @override
  String get btnUpdate => 'Update';

  @override
  String get isNotScheduled => 'Is Not Scheduled';

  @override
  String lessThanNClasses(int count) {
    return 'Less than $count classes';
  }

  @override
  String approxNStudents(int count) {
    return 'Approx $count students';
  }

  @override
  String get contactUsForAgreement => 'Contact us to set an agreement';

  @override
  String get titleSchoolBasic => 'School Basic';

  @override
  String get titleSchoolStandard => 'School Standard';

  @override
  String get titleSchoolPremium => 'School Premium';

  @override
  String get titleCustomAgreement => 'Custom Agreement';

  @override
  String get badgePopular => 'Popular';

  @override
  String get priceAgreement => 'Agreement';

  @override
  String get featureFlexibleClassCounts => 'Flexible class counts';

  @override
  String get featureFlexibleStudentCounts => 'Flexible student counts';

  @override
  String get featureExamCorrection => 'Exam correction';

  @override
  String get featureAbsenceManagement => 'Absence management';

  @override
  String get featureLessonsPlanner => 'Lessons planner';

  @override
  String get btnContactUs => 'Contact Us';

  @override
  String get licenseError => 'License Error';

  @override
  String get getALicense => 'Get a License';

  @override
  String get goHome => 'Go Home';

  @override
  String routeNotFound(String uri) {
    return 'Route not found: $uri';
  }

  @override
  String get aboutHomeTooltip => 'Home';

  @override
  String get aboutAppBarTitle => 'About Seg-Dude';

  @override
  String get aboutHeroChip => 'OUR STORY';

  @override
  String get aboutHeroTitle => 'About Seg-Dude';

  @override
  String get aboutHeroSubtitle =>
      'Simplifying school management through smart, modern technology.';

  @override
  String get aboutScrollToExplore => 'Scroll to explore';

  @override
  String get aboutWhoWeAreChip => 'WHO WE ARE';

  @override
  String get aboutWhoWeAreTitle => 'Who We Are';

  @override
  String get aboutWhoWeAreDescription =>
      'Seg-Dude is a modern school management platform designed to simplify the daily operations of educational institutions. Our goal is to provide an efficient, secure, and user-friendly solution that connects school administrators, teachers, students, and parents through an intuitive digital experience.';

  @override
  String get aboutOurMissionTitle => 'Our Mission';

  @override
  String get aboutOurMissionDescription =>
      'Our mission is to make school management easier by providing practical digital tools that improve organization, simplify scheduling, and support a better educational environment for schools.';

  @override
  String get aboutWhatWeOfferChip => 'WHAT WE OFFER';

  @override
  String get aboutWhatWeOfferTitle => 'What We Offer';

  @override
  String get aboutFeatureTeacherManagementTitle => 'Teacher Management';

  @override
  String get aboutFeatureTeacherManagementDesc =>
      'Organize teacher profiles, availability, and workload.';

  @override
  String get aboutFeatureClassSchedulingTitle => 'Class Scheduling';

  @override
  String get aboutFeatureClassSchedulingDesc =>
      'Generate conflict-free schedules in a few clicks.';

  @override
  String get aboutFeatureSimpleInterfaceTitle => 'Simple & Modern Interface';

  @override
  String get aboutFeatureSimpleInterfaceDesc =>
      'A clean experience built for everyday school staff.';

  @override
  String get aboutFeatureFastWorkflowTitle => 'Fast and Organized Workflow';

  @override
  String get aboutFeatureFastWorkflowDesc =>
      'Reduce manual work and keep everything in one place.';

  @override
  String get aboutComingSoonChip => 'COMING SOON';

  @override
  String get aboutWhatsNextTitle => 'What\'s Next';

  @override
  String get aboutComingSoonIntro =>
      'Seg-Dude is continuously evolving. Here\'s a glimpse of what we\'re building next.';

  @override
  String get aboutComingSoonFooter =>
      'Seg-Dude is continuously evolving. We\'re working on new features that will make school management even smarter and more efficient.';

  @override
  String get aboutSoonBadge => 'Soon';

  @override
  String get aboutComingSoonStudentManagementTitle => 'Student Management';

  @override
  String get aboutComingSoonStudentManagementDesc =>
      'Full student profiles and records in one place.';

  @override
  String get aboutComingSoonAttendanceTitle => 'Attendance System';

  @override
  String get aboutComingSoonAttendanceDesc =>
      'Track presence and absence with ease.';

  @override
  String get aboutComingSoonGradeManagementTitle => 'Grade Management';

  @override
  String get aboutComingSoonGradeManagementDesc =>
      'Record and analyze student performance.';

  @override
  String get aboutComingSoonParentPortalTitle => 'Parent Portal';

  @override
  String get aboutComingSoonParentPortalDesc =>
      'Keep parents informed and engaged.';

  @override
  String get aboutComingSoonNotificationsTitle => 'Notifications';

  @override
  String get aboutComingSoonNotificationsDesc =>
      'Timely alerts for staff, students, and parents.';

  @override
  String get aboutComingSoonAiToolsTitle => 'AI-powered Educational Tools';

  @override
  String get aboutComingSoonAiToolsDesc =>
      'Smart assistance for everyday school tasks.';

  @override
  String get aboutOurVisionTitle => 'Our Vision';

  @override
  String get aboutOurVisionDescription =>
      'We envision a future where every educational institution can manage its daily activities efficiently through innovative technology that saves time, reduces complexity, and supports academic success.';

  @override
  String get aboutOurValuesChip => 'OUR VALUES';

  @override
  String get aboutOurValuesTitle => 'Our Values';

  @override
  String get aboutValueInnovationTitle => 'Innovation';

  @override
  String get aboutValueInnovationDesc =>
      'Bringing modern technology to everyday school needs.';

  @override
  String get aboutValueSimplicityTitle => 'Simplicity';

  @override
  String get aboutValueSimplicityDesc =>
      'Keeping tools intuitive and easy to use.';

  @override
  String get aboutValueReliabilityTitle => 'Reliability';

  @override
  String get aboutValueReliabilityDesc =>
      'Building solutions schools can depend on.';

  @override
  String get aboutValueSecurityTitle => 'Security';

  @override
  String get aboutValueSecurityDesc =>
      'Protecting school and student data at every step.';

  @override
  String get aboutStayConnectedChip => 'STAY CONNECTED';

  @override
  String get aboutConnectWithUsTitle => 'Follow Us';

  @override
  String get connectWithUsTitle => 'Connect With Us';

  @override
  String get supportTitle => 'Support';

  @override
  String get supportSubtitle =>
      'Have questions or need help? Contact us directly.';

  @override
  String get emailUs => 'Email Us';

  @override
  String get sendUsEmailMessage =>
      'Send us email and we will reply as soon as possible';

  @override
  String get aboutConnectWithUsSubtitle =>
      'Follow Seg-Dude for tutorials, product updates, announcements, and new educational content.';

  @override
  String get aboutYouTubePlatform => 'YouTube';

  @override
  String get aboutYouTubeActionLabel => 'Visit channel';

  @override
  String get aboutYouTubeDescription =>
      'Watch tutorials, feature walkthroughs, updates, and future videos.';

  @override
  String get aboutInstagramPlatform => 'Instagram';

  @override
  String get aboutInstagramActionLabel => 'Follow us';

  @override
  String get aboutInstagramDescription =>
      'Follow us for news, announcements, behind-the-scenes updates, and community content.';

  @override
  String get aboutCopyright => '© 2026 Seg-Dude. All rights reserved.';

  @override
  String get aboutBackToHome => 'Back to Home';

  @override
  String get groups => 'Groups';

  @override
  String get groupsAreAssignedToAClass => 'groups are assigned to a class';

  @override
  String get groupsSplitClsIntoGroups => 'Split Class Into Groups';

  @override
  String get groupsSelectClassToSplit =>
      'Please select a class to split, click on the add button.';

  @override
  String get groupsAddSubjectFirst =>
      'Please Create subjects first to be able to split Classes';

  @override
  String get groupsAdd => 'Add Group';

  @override
  String get groupsApplyToOthers => 'Apply To Other Classes';

  @override
  String get groupsApplyToOthersDesc =>
      'Do you want to apply the same constraint to all classes in the same level?';

  @override
  String get groupsNotConf => 'No Groups configured yet';

  @override
  String get groupsMerge => 'Merge Classes';

  @override
  String get groupsMergeClasses => 'Merge classes into one group';

  @override
  String get groupsSelectClassesToMerge =>
      'Select at least two classes from this level.';

  @override
  String get groupsMergeWarningTitle => 'Split groups found';

  @override
  String get groupsMergeWarning =>
      'Some selected classes have split groups for this subject. Merging them will remove those split-group constraints. Continue?';

  @override
  String get groupsSelectTeacherFirstToMerge => 'Select a teacher first';

  @override
  String get groupsNoClassesForTeacherSubject =>
      'No eligible classes for this teacher and subject';

  @override
  String groupsClassesSelectedCount(int count) {
    return '$count classes selected';
  }

  @override
  String get groupsMergeSummary => 'Summary';

  @override
  String get groupsMergeSuccessMessage => 'Classes merged successfully';

  @override
  String get groupsSelectSubjectToMerge => 'Choose the subject for this merge';

  @override
  String get groupsSelectTeacherToMerge =>
      'Select the teacher responsible for this subject';

  @override
  String get groupsNoTeacherAssignedForSubject =>
      'No teacher is assigned for this subject — you can still merge its classes';

  @override
  String get groupsNoTeacherAssignedShort => 'No teacher assigned';

  @override
  String get groupsNoQualifiedTeacherMergeBlocked =>
      'No teacher is qualified for this subject at this level — merging is not available';

  @override
  String get deleteSubjectWarning =>
      'Teachers and groups associated with this subjcet will also be deleted.';

  @override
  String get number => 'Number';

  @override
  String get id => 'Id';

  @override
  String get grouping => 'Grouping';

  @override
  String get notes => 'Notes';

  @override
  String get noMatchingRecordsFound => 'No matching records found';

  @override
  String get supervisor => 'Supervisor';

  @override
  String get loadFromFile => 'Load from file';

  @override
  String get noSavedScheduleFound => 'No saved schedule found';

  @override
  String get clickToCreateNewSchedule => 'Click to create a new schedule';

  @override
  String get creationOptions => 'Options for creating a new schedule';

  @override
  String get chooseHowCreate => 'Choose how to create a new schedule.';

  @override
  String get collapse => 'Collapse';

  @override
  String get noGaps => 'Generate a schedule with no gaps (Student-biased)';

  @override
  String get teacherBias =>
      'Generate a schedule with groups of teachers (Teacher-biased)';

  @override
  String get studFirst => 'Student first';

  @override
  String get teacherFirst => 'Teacher first';

  @override
  String get ifNoneSelected => '(If no class is selected, then all classes)';

  @override
  String get ifSubjetMultiTeachers =>
      'If the subject has more than one teacher, the system of periods and groups is applied.';

  @override
  String get teachersCoexist =>
      'Teachers of a particular subject may be present in school during the same period.';

  @override
  String get licenseWarning => 'Data may be incorrect without premium license';

  @override
  String get licenseWarningDesc =>
      'Please get a premium license to get correct data.';

  @override
  String get schoolSeason => 'School Season';

  @override
  String get subjRequireRooms => 'Subject requires room';

  @override
  String get freeResourcesTabTitle => 'Free Resources';

  @override
  String freeResourcesForLevel(String level) {
    return 'Free Resources - Level $level';
  }

  @override
  String get freeClassesLabel => 'Free Classes';

  @override
  String get freeQualifiedTeachersLabel => 'Available Teachers';

  @override
  String get freeRoomsLabel => 'Free Rooms';

  @override
  String get noneLabel => 'None';

  @override
  String get noFreeSlotsThisDay => 'No free slots this day';

  @override
  String get noFreeSlotsAvailable => 'No free slots available';

  @override
  String get freeForAllClasses => 'All levels free';

  @override
  String get freeForLevelClasses => 'Whole level free';

  @override
  String get freeForSomeClasses => 'Some classes free';

  @override
  String levelNumberFallback(String id) {
    return 'Level $id';
  }

  @override
  String get tapLevelForDetailsHint =>
      'Tap a level to see available teachers & rooms';

  @override
  String forcedSubjectInAllowedRooms(String subjectName, String roomName) {
    return '$subjectName is forced to a specific room, but it appears in the allowed subjects of $roomName. Continue will remove it from the allowed subjects of $roomName.';
  }
}
