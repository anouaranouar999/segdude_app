// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Lkout';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get error => 'Erreur';

  @override
  String get welcome => 'Bienvenue';

  @override
  String get timetable => 'tableau';

  @override
  String get timetableCreate => 'Créer un tableau';

  @override
  String get timetableResult => 'Résultat';

  @override
  String get fieldRequired => 'Obligatoire';

  @override
  String get mustBePositive => 'Doit être ≥ 1';

  @override
  String get idAlreadyUsed => 'Identifiant déjà utilisé';

  @override
  String get minTwoChars => 'Min. 2 caractères';

  @override
  String get invalidHoursFormat => 'Format : niveauId:heures — ex. 1:6,2:4';

  @override
  String get levelsRequired => 'Entrez au moins un niveau — ex. 1,2';

  @override
  String get invalidFormat => 'Format invalide — ex. 1,2';

  @override
  String get slotRange => 'Le créneau doit être entre 1 et 24';

  @override
  String get slotAlreadyUsed => 'Ce créneau est déjà une pause';

  @override
  String get dayRange => 'Le jour doit être entre 1 et 7';

  @override
  String get minTwo => 'Doit être ≥ 2';

  @override
  String get selectASubject => 'Sélectionner une matière';

  @override
  String get searchTeacherHint => 'Rechercher un enseignant...';

  @override
  String get noTeachersForSubject => 'Aucun enseignant pour cette matière';

  @override
  String get addRooms => 'Ajouter des salles';

  @override
  String get addSubject => 'Ajouter une matière';

  @override
  String get editTeacher => 'Modifier l\'enseignant';

  @override
  String teacherUpdatedSuccessfully(String name) {
    return '$name modifié avec succès';
  }

  @override
  String get noTeacherScheduleAvailable =>
      'Aucun emploi du temps enseignant disponible';

  @override
  String teacherNumberFallback(String id) {
    return 'Enseignant $id';
  }

  @override
  String dayNumberFallback(String id) {
    return 'Jour $id';
  }

  @override
  String subjectNumberFallback(String id) {
    return 'Matière $id';
  }

  @override
  String classNumberFallback(String id) {
    return 'Classe $id';
  }

  @override
  String roomNumberFallback(String id) {
    return 'Salle $id';
  }

  @override
  String get editSubject => 'Modifier la matière';

  @override
  String get editRoom => 'Modifier la salle';

  @override
  String get save => 'Enregistrer';

  @override
  String get addTeacher => 'Ajouter un enseignant';

  @override
  String get addABreakHour => 'Ajouter une pause';

  @override
  String get addEdit => 'Ajouter/Modifier';

  @override
  String get allDataCleared => 'Toutes les données effacées !';

  @override
  String get awesome => 'Génial';

  @override
  String get cancel => 'Annuler';

  @override
  String get chooseLevel => 'Choisir le niveau...';

  @override
  String get clearOverrides => 'Effacer les dérogations';

  @override
  String get confirmPay => 'Confirmer & Payer';

  @override
  String get confirmPayment => 'Confirmer le paiement';

  @override
  String get continueBtn => 'Continuer';

  @override
  String get createSchedule => 'Créer un emploi du temps';

  @override
  String get createSubject => 'Créer une matière';

  @override
  String get enterPhoneNumber => 'Entrez le numéro de téléphone';

  @override
  String get errorMsg => 'Erreur';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get generate => 'Générer';

  @override
  String get info => 'Info';

  @override
  String get insufficientTeachers => 'Enseignants insuffisants';

  @override
  String get language => 'Langue';

  @override
  String get manualOverridesPlanner => 'Planificateur de dérogations manuelles';

  @override
  String get minutesMustBeBetween1And59 =>
      'Les minutes doivent être entre 1 et 59 !';

  @override
  String get noRoomsConfiguredYet => 'Aucune salle configurée pour l\'instant.';

  @override
  String get noSubjectsAddedYet => 'Aucune matière ajoutée pour l\'instant.';

  @override
  String get noTeachersAssignedYet =>
      'Aucun enseignant assigné pour l\'instant. Utilisez le menu ci-dessus pour désactiver l\'inclusion des enseignants';

  @override
  String get ok => 'OK';

  @override
  String get confirmQuestion => 'Vous êtes sûr ?';

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String get pinSlot => 'Épingler le créneau';

  @override
  String get pleaseAddRooms => 'Veuillez ajouter des salles';

  @override
  String get pleaseAddSubjects => 'Veuillez ajouter des matières';

  @override
  String get pleaseAddTeachers =>
      'Veuillez ajouter des enseignants OU désactiver l\'inclusion des enseignants dans le tableau';

  @override
  String get includeTeachersInPayload =>
      'Inclure les enseignants dans le tableau';

  @override
  String get includeTeachersInPayloadHint =>
      'When disabled, the generator sends placeholder teachers to the backend while still allowing schedule creation.';

  @override
  String get pleaseSelectAClassFirst =>
      'Veuillez d\'abord sélectionner une classe !';

  @override
  String get pleaseSelectAtLeastOneWorkingD =>
      'Veuillez sélectionner au moins un jour ouvrable';

  @override
  String get scheduleResult => 'Résultat de l\'emploi du temps';

  @override
  String get scheduleSkeleton => 'Squelette de l\'emploi du temps';

  @override
  String get scheduleDataNotFound => 'Données d\'emploi du temps introuvables.';

  @override
  String get send => 'Envoyer';

  @override
  String get timingConstraints => 'Contraintes horaires';

  @override
  String get tryAnyway => 'Essayer quand même';

  @override
  String get upgradeToPremium => 'Passer à la version Premium';

  @override
  String get yourPremiumFeaturesHaveBeenUnl =>
      'Vos fonctionnalités Premium ont été débloquées.';

  @override
  String get logout => 'Déconnexion';

  @override
  String get confirmLogoutTitle => 'Confirmer la déconnexion';

  @override
  String get confirmLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get alreadyHave => 'Vous avez déjà un compte ?';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get profile => 'Profil';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get firstName => 'Prénom';

  @override
  String get institution => 'Institution';

  @override
  String get lastName => 'Nom';

  @override
  String get phone => 'Téléphone';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordDescription =>
      'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation de votre mot de passe.';

  @override
  String get emailNotConfirmedError => 'E-mail non confirmé.';

  @override
  String get pleaseConfirmEmail => 'Veuillez confirmer votre e-mail';

  @override
  String get emailWillBeSentTo => 'Un lien de confirmation sera envoyé à : ';

  @override
  String get errorPrefix => 'Erreur:';

  @override
  String get signInWelcome => 'Bienvenue Connexion';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer un e-mail';

  @override
  String get invalidEmail => 'E-mail invalide';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer un mot de passe';

  @override
  String get shortPassword =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get pleaseSelectRole => 'Veuillez sélectionner un rôle';

  @override
  String get welcomesegtotimetable => 'Bienvenue sur seg-timetable';

  @override
  String get noMorePlaceAnimation => 'Plus de place pour l\'animation';

  @override
  String get emptyFirstName => 'prénomVide';

  @override
  String get emptyLastName => 'nomVide';

  @override
  String get fillAllFields => 'remplirTousLesChamps';

  @override
  String get passwordNotMatch => 'motDePasseNonIdentique';

  @override
  String get roleDirector => 'Directeur';

  @override
  String get roleSupervisor => 'Superviseur';

  @override
  String get roleTeacher => 'Enseignant';

  @override
  String get roleStudent => 'Étudiant';

  @override
  String get roleLabel => 'rôle';

  @override
  String get signInLabel => 'se_connecter';

  @override
  String get optional => 'Facultatif';

  @override
  String get guide => 'Guide';

  @override
  String get subject => 'Matière';

  @override
  String get teacher => 'Enseignant';

  @override
  String get teachers => 'Enseignants';

  @override
  String get room => 'Salle';

  @override
  String get rooms => 'Salles';

  @override
  String get restricted => 'restreint';

  @override
  String get consecutive => 'consécutif';

  @override
  String get levels => 'Niveaux';

  @override
  String get subjects => 'Matières';

  @override
  String get weeklyHours => 'Heures hebdomadaires';

  @override
  String get classes => 'Classes';

  @override
  String get hours => 'Heures';

  @override
  String get filterTeachersBySubject => 'Filtrer les enseignants par matière';

  @override
  String get allSubjects => 'Toutes les matières';

  @override
  String get searchForATeacher => 'Rechercher un enseignant';

  @override
  String get selectATeacherToViewSchedule =>
      'Sélectionnez un enseignant pour voir son emploi du temps.';

  @override
  String roomAddedSuccessfully(String name) {
    return '« $name » ajouté avec succès';
  }

  @override
  String roomRemoved(String name) {
    return '« $name » supprimé';
  }

  @override
  String roomUpdatedSuccessfully(String name) {
    return '« $name » mis à jour avec succès';
  }

  @override
  String teacherAddedSuccessfully(String name) {
    return '$name ajouté avec succès';
  }

  @override
  String teacherRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String nLevelsSelected(int count) {
    return '$count niveau(x) sélectionné(s)';
  }

  @override
  String nSubjectsSelected(int count) {
    return '$count matière(s) sélectionnée(s)';
  }

  @override
  String capacityValue(int value) {
    return 'Capacité : $value';
  }

  @override
  String maxHoursPerWeekValue(int value) {
    return 'max ${value}h/sem';
  }

  @override
  String classesInLevel(String level) {
    return 'Classes de $level';
  }

  @override
  String templatePlannerTitle(String className) {
    return 'Planificateur : $className';
  }

  @override
  String pinLessonForClass(String className) {
    return 'Épingler un cours pour $className';
  }

  @override
  String dayAndSlot(String day, int slot) {
    return '$day, Créneau $slot';
  }

  @override
  String slotNumber(int number) {
    return 'Créneau $number';
  }

  @override
  String nPinned(int count) {
    return '$count épinglé(s)';
  }

  @override
  String get sectionBasicInformation => 'INFORMATIONS DE BASE';

  @override
  String get sectionRestrictionsOptional => 'RESTRICTIONS  (FACULTATIF)';

  @override
  String get sectionConstraints => 'CONTRAINTES';

  @override
  String get cardRoomName => 'NOM DE LA SALLE';

  @override
  String get cardCapacityOptional => 'CAPACITÉ  (FACULTATIF)';

  @override
  String get cardAllowedLevels => 'NIVEAUX AUTORISÉS';

  @override
  String get cardAllowedSubjects => 'MATIÈRES AUTORISÉES';

  @override
  String get cardUsedOnlyFor => 'UTILISÉE UNIQUEMENT POUR';

  @override
  String get cardTeacherName => 'NOM DE L\'ENSEIGNANT';

  @override
  String get cardSubject => 'MATIÈRE';

  @override
  String get cardQualifiedLevels => 'NIVEAUX QUALIFIÉS';

  @override
  String get cardMaxHoursWeekOptional => 'HEURES MAX / SEMAINE  (FACULTATIF)';

  @override
  String get cardConsecutiveHours => 'HEURES CONSÉCUTIVES';

  @override
  String get tooltipRoomName =>
      'Un nom unique qui identifie cette salle. Peut être un numéro, une étiquette ou une description.';

  @override
  String get tooltipCapacity =>
      'Nombre maximum d\'élèves que cette salle peut accueillir. Le planificateur évite la surpopulation. Valeur par défaut : 40.';

  @override
  String get tooltipAllowedLevels =>
      'Laissez vide pour autoriser tous les niveaux. Sélectionnez des niveaux spécifiques pour réserver cette salle.';

  @override
  String get tooltipAllowedSubjects =>
      'Laissez vide pour autoriser toutes les matières. Sélectionnez des matières pour restreindre cette salle (ex. un labo pour la chimie uniquement).';

  @override
  String get tooltipUsedOnlyFor =>
      'Sélectionnez une matière pour la rendre obligatoire dans cette salle (ex. un labo pour la chimie uniquement).';

  @override
  String get tooltipTeacherName =>
      'Doit être unique. Utilisé pour identifier cet enseignant dans l\'emploi du temps.';

  @override
  String get tooltipTeacherSubject =>
      'Chaque enseignant est affecté à une matière. Le planificateur utilise ceci pour associer les enseignants aux classes.';

  @override
  String get tooltipQualifiedLevels =>
      'Niveaux scolaires ou groupes d\'années que cet enseignant est autorisé à enseigner. Sélectionnez tout ce qui s\'applique.';

  @override
  String get tooltipMaxHoursWeek =>
      'Empêche d\'assigner plus que ce nombre d\'heures à cet enseignant en une semaine.';

  @override
  String get tooltipConsecutiveHours =>
      'Lorsqu\'activé, le planificateur regroupe les sessions de cet enseignant en un bloc continu.';

  @override
  String get hintEnterRoomName => 'Entrez le nom de la salle';

  @override
  String get hintCapacity => 'ex. 30';

  @override
  String get hintEnterTeacherName => 'Entrez le nom de l\'enseignant';

  @override
  String get hintSelectSubject => 'Sélectionnez une matière';

  @override
  String get hintMaxHours => 'ex. 20';

  @override
  String get capacityDescription =>
      'Nombre maximum d\'élèves. Laissez vide pour utiliser la valeur par défaut (40).';

  @override
  String get allowedLevelsDescription =>
      'Seuls les niveaux sélectionnés sont autorisés. Laissez vide pour autoriser tous les niveaux.';

  @override
  String get allowedSubjectsDescription =>
      'Laissez vide pour autoriser toutes les matières. Sélectionnez des matières pour restreindre cette salle.';

  @override
  String get usedOnlyForDescription =>
      'Obliger le matériel à utiliser cette salle seulement (e.g. laboratoire de chimie uniquement).';

  @override
  String get qualifiedLevelsDescription =>
      'Sélectionnez chaque niveau que cet enseignant est qualifié pour enseigner.';

  @override
  String get maxHoursWeekDescription =>
      'Laissez vide pour aucune limite hebdomadaire. Utile pour les enseignants à temps partiel.';

  @override
  String get requireConsecutiveHours => 'Exiger des heures consécutives';

  @override
  String get consecutiveHoursDescription =>
      'Les cours de l\'enseignant seront planifiés dos à dos.';

  @override
  String get validationRoomNameRequired => 'Le nom de la salle est obligatoire';

  @override
  String get validationNameMinTwoChars =>
      'Le nom doit contenir au moins 2 caractères';

  @override
  String get validationRoomNameAlreadyExists =>
      'Une salle avec ce nom existe déjà';

  @override
  String get validationMustBeNumberGteOne => 'Doit être un nombre ≥ 1';

  @override
  String get validationTeacherNameRequired =>
      'Le nom de l\'enseignant est obligatoire';

  @override
  String get validationTeacherNameAlreadyExists =>
      'Un enseignant avec ce nom existe déjà';

  @override
  String get validationSelectSubjectOrCreate =>
      'Veuillez sélectionner une matière ou en créer une';

  @override
  String get validationSelectAtLeastOneLevel =>
      'Sélectionnez au moins un niveau';

  @override
  String get validationSelectSubject => 'Veuillez sélectionner une matière';

  @override
  String get validationSelectTeacher => 'Veuillez sélectionner un enseignant';

  @override
  String get validationSelectRoom => 'Veuillez sélectionner une salle';

  @override
  String get noLevelsDefinedYet => 'Aucun niveau défini pour l\'instant.';

  @override
  String get noSubjectsDefinedYet => 'Aucune matière définie pour l\'instant.';

  @override
  String get noRoomsAddedYet => 'Aucune salle ajoutée pour l\'instant';

  @override
  String get noRoomsAddedYetSubtitle =>
      'Remplissez le formulaire ou utilisez Générer pour ajouter des salles';

  @override
  String get noTeachersAddedYet => 'Aucun enseignant ajouté pour l\'instant';

  @override
  String get noTeachersAddedYetSubtitle =>
      'Remplissez le formulaire et appuyez sur Ajouter un enseignant';

  @override
  String get unknownSubject => 'Matière inconnue';

  @override
  String get unknownTeacher => 'Enseignant inconnu';

  @override
  String get unknownRoom => 'Salle inconnue';

  @override
  String get roomsAdded => 'Salles ajoutées';

  @override
  String get teachersAdded => 'Enseignants ajoutés';

  @override
  String get removeRoom => 'Supprimer la salle';

  @override
  String get removeTeacher => 'Supprimer l\'enseignant';

  @override
  String get swipeLeftToDeleteRoom =>
      'Glissez à gauche pour supprimer une salle';

  @override
  String get addRoom => 'Ajouter une salle';

  @override
  String get createNewSubject => 'Créer une nouvelle matière';

  @override
  String get generateRooms => 'Générer des salles';

  @override
  String get generateRoomsDescription =>
      'Ajoutez rapidement plusieurs salles avec un modèle de numérotation.';

  @override
  String get numberOfRooms => 'Nombre de salles';

  @override
  String get numberOfRoomsHint => 'ex. 10';

  @override
  String get namePatternLabel => 'Modèle de nom  (# → numéro)';

  @override
  String get namePatternHint => 'ex. Salle # → Salle 1, Salle 2…';

  @override
  String get helpSheetRoomsTitle => 'Ajouter des salles — Guide';

  @override
  String get helpSheetTeachersTitle => 'Ajouter un enseignant — Guide';

  @override
  String get helpSheetSubtitle => 'Ce qu\'il faut saisir dans chaque champ';

  @override
  String get helpEntryRoomNameTitle => 'Nom de la salle';

  @override
  String get helpEntryRoomNameBody =>
      'Un nom unique pour identifier cette salle dans l\'emploi du temps.\n\n• Au moins 2 caractères, doit être unique\n• Exemples : « Salle 101 », « Labo Sciences », « Salle Informatique », « Grande Bibliothèque »';

  @override
  String get helpEntryCapacityTitle => 'Capacité';

  @override
  String get helpEntryCapacityBody =>
      'Le nombre maximum d\'élèves que cette salle peut accueillir à la fois.\n\n• Laissez vide pour utiliser la capacité par défaut (40 élèves)\n• Le planificateur l\'utilise pour éviter la surpopulation\n• Exemple : Entrez « 25 » si le labo ne dispose que de 25 places';

  @override
  String get helpEntryAllowedLevelsTitle => 'Niveaux autorisés';

  @override
  String get helpEntryAllowedLevelsBody =>
      'Restreignez cette salle à des niveaux scolaires spécifiques uniquement.\n\n• Laissez tous non sélectionnés pour autoriser tous les niveaux\n• Sélectionnez un ou plusieurs niveaux pour réserver cette salle\n• Exemple : Une « Salle CM2 » réservée uniquement aux élèves de CM2';

  @override
  String get helpEntryAllowedSubjectsTitle => 'Matières autorisées';

  @override
  String get helpEntryAllowedSubjectsBody =>
      'Restreignez cette salle à des matières spécifiques uniquement.\n\n• Laissez tous non sélectionnés pour autoriser toutes les matières\n• Sélectionnez des matières si la salle dispose d\'équipements spéciaux\n• Exemple : Un « Labo de Chimie » ne doit être utilisé que pour la Chimie';

  @override
  String get helpEntryGenerateRoomsTitle =>
      'Générer des salles (Action rapide)';

  @override
  String get helpEntryGenerateRoomsBody =>
      'Utilisez le bouton « Générer » dans la barre d\'outils pour créer plusieurs salles à la fois.\n\n• Entrez le nombre de salles dont vous avez besoin\n• Utilisez # comme espace réservé pour le numéro de la salle\n• Exemple : « Salle # » avec 5 → crée « Salle 1 » à « Salle 5 »\n• Les salles générées utilisent la capacité par défaut (40) sans restrictions';

  @override
  String get helpEntryDeletingRoomTitle => 'Supprimer une salle';

  @override
  String get helpEntryDeletingRoomBody =>
      'Vous pouvez retirer une salle de la liste après l\'avoir ajoutée.\n\n• Glissez à gauche sur une salle pour la supprimer\n• Ou survolez la tuile et appuyez sur l\'icône 🗑 à droite';

  @override
  String get helpEntryTeacherNameTitle => 'Nom de l\'enseignant';

  @override
  String get helpEntryTeacherNameBody =>
      'Le nom complet de l\'enseignant à ajouter à l\'emploi du temps.\n\n• Au moins 2 caractères, doit être unique\n• Exemples : « Sarah Ibrahim », « M. Ahmed », « Dr. Leila »';

  @override
  String get helpEntryTeacherSubjectTitle => 'Matière';

  @override
  String get helpEntryTeacherSubjectBody =>
      'La matière que cet enseignant est qualifié pour enseigner.\n\n• Chaque enseignant est lié à exactement une matière\n• Le planificateur l\'utilise pour affecter le bon enseignant à chaque classe\n• Si la matière est manquante, appuyez sur « Créer une nouvelle matière » pour l\'ajouter d\'abord';

  @override
  String get helpEntryQualifiedLevelsTitle => 'Niveaux qualifiés';

  @override
  String get helpEntryQualifiedLevelsBody =>
      'Les niveaux scolaires que cet enseignant peut enseigner.\n\n• Sélectionnez au moins un niveau\n• Choisissez tous les niveaux applicables — un enseignant peut couvrir plusieurs niveaux\n• Exemple : Sélectionnez « CE2 » et « CM1 » si l\'enseignant peut gérer les deux';

  @override
  String get helpEntryMaxHoursTitle => 'Heures max / Semaine';

  @override
  String get helpEntryMaxHoursBody =>
      'Le nombre maximum d\'heures d\'enseignement par semaine.\n\n• Laissez vide pour aucune limite\n• Utile pour les enseignants à temps partiel ou pour éviter une surcharge\n• Exemple : Entrez « 18 » pour limiter l\'enseignant à 18 heures/semaine';

  @override
  String get helpEntryConsecutiveHoursTitle => 'Heures consécutives';

  @override
  String get helpEntryConsecutiveHoursBody =>
      'Contrôle si les cours de cet enseignant doivent être planifiés dos à dos.\n\n• ✅ Coché — Le planificateur regroupe les cours en un bloc continu\n• ☐ Non coché — Les cours peuvent être répartis librement dans la journée\n• Utile pour les enseignants qui préfèrent enseigner toutes leurs classes en une session';

  @override
  String get createSubjectEmptyHint =>
      'Sélectionnez un niveau et appuyez sur le bouton + (Ctrl+A/Cmd+A) pour ajouter des matières\nsi la matière est enseignée à ce niveau, augmentez les heures hebdomadaires, sinon laissez à 0\nconsultez la documentation pour plus d\'informations';

  @override
  String get addSubjectTooltip => 'Ajouter une matière (Ctrl+A/Cmd+A)';

  @override
  String get levelSelected => 'Sélectionné ✓';

  @override
  String get levelTapToSelect => 'Appuyez pour sélectionner';

  @override
  String get daySlotHeader => 'Jour / Créneau';

  @override
  String get breakTime => 'Pause';

  @override
  String get selectLevel => 'Sélectionner un niveau';

  @override
  String get selectLevelToViewClasses =>
      'Sélectionnez un niveau pour afficher les classes.';

  @override
  String get selectClassToStartPinning =>
      'Sélectionnez une classe dans la barre latérale pour commencer à épingler des créneaux.';

  @override
  String get pleaseAddLevelsFirst =>
      'Veuillez d\'abord ajouter des niveaux sur la page principale.';

  @override
  String get pleaseCompleteWorkingDaysConfig =>
      'Veuillez d\'abord compléter la configuration des jours ouvrables et des créneaux sur la première page.';

  @override
  String get templatePlannerSubtitle =>
      'Forcez des matières, enseignants et salles spécifiques. Les classes épinglées sont strictement respectées par le générateur.';

  @override
  String get clearedOverridesForClass =>
      'Dérogations effacées pour cette classe.';

  @override
  String get selectSubjectFirst => 'Sélectionnez d\'abord une matière';

  @override
  String get noQualifiedTeachersForLevelSubject =>
      'Aucun enseignant qualifié pour ce niveau et cette matière';

  @override
  String get dayMonday => 'Lundi';

  @override
  String get dayTuesday => 'Mardi';

  @override
  String get dayWednesday => 'Mercredi';

  @override
  String get dayThursday => 'Jeudi';

  @override
  String get dayFriday => 'Vendredi';

  @override
  String get daySaturday => 'Samedi';

  @override
  String get daySunday => 'Dimanche';

  @override
  String get whileGeneratingTitle =>
      'Veuillez patienter pendant que l\'emploi du temps est généré...';

  @override
  String get whileGeneratingDescription =>
      'Une fois l\'emploi du temps généré, vous serez redirigé vers la page de détails.\nLe solveur (algorithme) s\'exécutera sur le serveur en testant toutes les combinaisons possibles pour trouver la solution OPTIMALE. \nUn manque de ressources entraînera des solutions POSSIBLES et non OPTIMALES ou impossibles à générer.';

  @override
  String get whileGeneratingWarning =>
      'Si cela prend trop de temps, cela signifie que le solveur va échouer';

  @override
  String get generatingStatusInitializing =>
      'Initialisation de la génération de l\'emploi du temps...';

  @override
  String get generatingStatusEvaluating => 'Évaluation des contraintes...';

  @override
  String get generatingStatusSearching =>
      'Recherche de l\'emploi du temps optimal...';

  @override
  String get generatingStatusOptimizing =>
      'Optimisation de l\'emploi du temps...';

  @override
  String get generatingStatusFinalizing =>
      'Finalisation de l\'emploi du temps...';

  @override
  String estimatedTime(String duration) {
    return 'Temps estimé : $duration';
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
  String get homeHeroTitle =>
      'Créez des emplois du temps\nparfaits\nen quelques minutes';

  @override
  String get homeHeroSubtitle =>
      'Fini les tableaux complexes. seg-timetable assigne automatiquement les enseignants, les salles et les créneaux pour que chaque classe obtienne l\'emploi du temps qu\'elle mérite — sans conflits.';

  @override
  String get homeInstitutionNotice =>
      'Principalement conçu pour les établissements scolaires, mais utilisable par toute institution ayant besoin d\'emplois du temps.';

  @override
  String get homeCtaButton => 'Créer votre emploi du temps';

  @override
  String get homeSocialProof => 'Gratuit pour commencer · Aucun compte requis';

  @override
  String get homeWeeklySchedulePreview =>
      'Aperçu de l\'emploi du temps hebdomadaire';

  @override
  String get homeFeaturesTitle =>
      'Tout ce dont vous avez besoin pour planifier plus intelligemment';

  @override
  String get homeFeaturesSubtitle =>
      'Des fonctionnalités puissantes dans une interface claire et intuitive.';

  @override
  String get homeFeatureInstantGenerationTitle => 'Génération instantanée';

  @override
  String get homeFeatureInstantGenerationDesc =>
      'Notre algorithme traite vos contraintes et produit un emploi du temps complet et sans conflits en quelques secondes.';

  @override
  String get homeFeatureTeacherRoomTitle =>
      'Gestion des enseignants et des salles';

  @override
  String get homeFeatureTeacherRoomDesc =>
      'Ajoutez des enseignants, définissez les matières et attribuez les salles. Le planificateur respecte les disponibilités et les capacités.';

  @override
  String get homeFeatureManualOverridesTitle => 'Modifications manuelles';

  @override
  String get homeFeatureManualOverridesDesc =>
      'Besoin de fixer un créneau spécifique ? Utilisez le planificateur de modifications manuelles pour verrouiller des affectations tout en optimisant le reste.';

  @override
  String get homeFeatureExportPdfTitle => 'Exporter en PDF';

  @override
  String get homeFeatureExportPdfDesc =>
      'Imprimez ou partagez votre emploi du temps en PDF professionnel en un clic — prêt pour les tableaux d\'affichage ou les e-mails du personnel.';

  @override
  String get homeHowItWorksChip => 'COMMENT ÇA MARCHE';

  @override
  String get homeHowItWorksTitle =>
      'De la page blanche à l\'emploi du temps publié\nen quatre étapes simples';

  @override
  String get homeStep1Title => 'Définir les contraintes horaires';

  @override
  String get homeStep1Desc =>
      'Choisissez vos jours ouvrables, définissez les heures de début et de fin, et marquez les pauses.';

  @override
  String get homeStep2Title => 'Ajouter enseignants, matières et salles';

  @override
  String get homeStep2Desc =>
      'Saisissez toutes les personnes et ressources dont le planificateur a besoin.';

  @override
  String get homeStep3Title => 'Générer';

  @override
  String get homeStep3Desc =>
      'Appuyez sur générer et regardez l\'algorithme construire un emploi du temps parfaitement équilibré pour chaque classe.';

  @override
  String get homeStep4Title => 'Réviser et exporter';

  @override
  String get homeStep4Desc =>
      'Inspectez le résultat, appliquez les modifications manuelles nécessaires, puis exportez un PDF soigné.';

  @override
  String get homeStartForFree => 'Commencer gratuitement';

  @override
  String get homeBottomCtaTitle =>
      'Prêt à créer votre premier emploi du temps ?';

  @override
  String get homeBottomCtaSubtitle =>
      'Il suffit de quelques minutes pour configurer votre établissement et laisser l\'algorithme faire le travail.';

  @override
  String get homeBottomCtaButton => 'Créer votre emploi du temps maintenant';

  @override
  String get homeCopyright => 'Lkout © 2026';

  @override
  String get startFreshTitle => 'Repartir à zéro ?';

  @override
  String get startFreshContent =>
      'Cela supprimera toutes les données enregistrées, y compris les enseignants, les matières, les salles et les paramètres de l\'emploi du temps. Êtes-vous sûr ?';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get startFresh => 'Repartir à zéro';

  @override
  String get lastGenerated => 'Dernier généré';

  @override
  String get selectWorkingDays => 'Sélectionner les jours ouvrables';

  @override
  String get pleaseSelectOneDayOrderMatters =>
      'Veuillez sélectionner au moins un jour — L\'ORDRE EST IMPORTANT :';

  @override
  String get workingHoursTitle => 'Heures de travail  (ex. 8 = 08:00)';

  @override
  String get workingHoursHint =>
      'Entrez la première et la dernière heure de la journée scolaire.';

  @override
  String get startHourRequired => 'L\'heure de début est requise';

  @override
  String get enterWholeNumber => 'Entrez un nombre entier';

  @override
  String get mustBeBetween1And22 => 'Doit être entre 1 et 22';

  @override
  String get startHourLabel => 'de';

  @override
  String get endHourRequired => 'L\'heure de fin est requise';

  @override
  String get cannotExceed23 => 'Ne peut pas dépasser 23';

  @override
  String get mustBeAfterStartHour => 'Doit être après l\'heure de début';

  @override
  String get endHourLabel => 'à';

  @override
  String get timeslotsFormula => 'Créneaux = heure de fin − heure de début';

  @override
  String get maxHoursPerStudentPerDay => 'Heures max par élève par jour';

  @override
  String get maxHoursPerDayHint =>
      'Une classe ne peut pas être planifiée pour plus d\'heures que cette valeur dans une seule journée.';

  @override
  String get pleaseSelectValidValue =>
      'Veuillez sélectionner une valeur valide (1 ou plus)';

  @override
  String get breakHoursTitle => 'Heures de pause';

  @override
  String get breakHoursHint =>
      'ex. Déjeuner 12:00–14:00 → sélectionnez 12 et 13.';

  @override
  String get pleaseSelectStartAndEndHoursFirst =>
      'Veuillez d\'abord sélectionner les heures de début et de fin';

  @override
  String get breakHourMustBeAfterStartHour =>
      'L\'heure de pause doit être après l\'heure de début';

  @override
  String get breakHourMustBeBeforeEndHour =>
      'L\'heure de pause doit être avant l\'heure de fin';

  @override
  String get breakSlots => 'Créneaux de pause :';

  @override
  String get noBreakHoursSelected => 'Aucune heure de pause sélectionnée';

  @override
  String get editSpecificDaySlots =>
      'Modifier les créneaux d\'un jour spécifique';

  @override
  String get clickDayToManageSlots =>
      'Cliquez sur un jour pour gérer ses créneaux actifs.';

  @override
  String get noDaysSelected => 'Aucun jour sélectionné';

  @override
  String get scheduleSummary => 'Résumé de l\'emploi du temps';

  @override
  String get summaryDaysPerWeek => 'Jours par semaine';

  @override
  String get summaryTimeslotsPerDay => 'Créneaux / jour';

  @override
  String get summaryMaxHoursPerDay => 'Heures max / jour';

  @override
  String get summaryBreakHours => 'Heures de pause';

  @override
  String get summarySelectedDays => 'Jours sélectionnés';

  @override
  String get nextLabel => 'Suivant';

  @override
  String get nextStageTooltip => 'Étape suivante';

  @override
  String get startByAddingLevels => 'Commencez par ajouter des niveaux';

  @override
  String get addLevelsInstructions =>
      'Ajoutez d\'abord les niveaux, puis les matières, puis les salles, puis les remplacements manuels';

  @override
  String get addLevels => 'Ajouter des niveaux';

  @override
  String get levelsColumnHeader => 'Niveaux';

  @override
  String get addLevel => 'Ajouter un niveau';

  @override
  String get removeLevelTooltip => 'Supprimer le niveau';

  @override
  String get selectLevelToViewDetailsHeader =>
      'Sélectionnez un niveau pour voir les détails';

  @override
  String detailsForLevel(String level) {
    return 'Détails de $level';
  }

  @override
  String get subjectsTaught => 'Matières enseignées';

  @override
  String get assignedTeachers => 'Enseignants assignés';

  @override
  String get availableRooms => 'Salles disponibles';

  @override
  String get manualOverridesSection => 'Modifications manuelles';

  @override
  String get noManualOverridesForLevel =>
      'Aucune modification manuelle configurée pour ce niveau.';

  @override
  String activeOverrideConstraints(int count) {
    return '$count contrainte(s) de remplacement actives épinglées pour les classes de ce niveau.';
  }

  @override
  String get pleaseSelectLevelFromLeft =>
      'Veuillez sélectionner un niveau à gauche pour afficher et gérer\nses matières, enseignants et salles.';

  @override
  String get allRoomsForcedNoFreeRooms =>
      'Toutes les salles sont imposées pour des matières spécifiques, ne laissant aucune salle libre pour les autres matières.';

  @override
  String get hasNoTeacher => 'n\'a pas d\'enseignant';

  @override
  String needHoursNoQualifiedTeacher(int hours, String subject, String level) {
    return '$level a besoin de $hours heures de \"$subject\" mais aucun enseignant n\'est qualifié, ajoutez un enseignant au niveau $level';
  }

  @override
  String notEnoughTeachersContent(
    String subject,
    int required,
    int available,
    int needed,
  ) {
    return 'Pas assez d\'enseignants pour $subject !\n\n• Requis : $required heures\n• Capacité disponible : $available heures\n\nConsidérez l\'ajout de ~$needed enseignant(s) supplémentaire(s).';
  }

  @override
  String get insufficientRoomsTitle => 'Salles insuffisantes';

  @override
  String get roomCapacityMayBeInsufficient =>
      'La capacité des salles peut être insuffisante';

  @override
  String get currentRooms => 'Salles actuelles :';

  @override
  String get predictedNeeded => 'Prévu nécessaire :';

  @override
  String get totalClassHoursWeek => 'Total heures-classe/semaine :';

  @override
  String get ratioPerRoom => 'Ratio par salle :';

  @override
  String get schedulerMayFail =>
      'Le planificateur peut échouer à trouver une solution. Envisagez d\'ajouter plus de salles.';

  @override
  String classesCount(int count) {
    return 'Classes : $count';
  }

  @override
  String get pdfLockedSlot => 'verrouillé';

  @override
  String get pdfDocumentName => 'My_Document';

  @override
  String get settings => 'Paramètres';

  @override
  String get print => 'Imprimer';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get noScheduleDataGoHome =>
      'Aucune donnée d\'emploi du temps trouvée. Retour à l\'accueil...';

  @override
  String get selectAClass => 'Sélectionner une classe';

  @override
  String get selectClassToViewSchedule =>
      'Sélectionnez une classe dans la liste pour afficher son emploi du temps.';

  @override
  String get scheduleGenerationFailed =>
      'La génération de l\'emploi du temps a échoué.';

  @override
  String get generalCategory => 'Général';

  @override
  String get noDetailsProvided => 'Aucun détail fourni.';

  @override
  String get noFurtherDiagnostics =>
      'Aucun diagnostic supplémentaire disponible.';

  @override
  String solutionHint(String hint) {
    return 'Conseil : $hint';
  }

  @override
  String clsCount(int count) {
    return '$count classe(s)';
  }

  @override
  String get saveExit => 'Enregistrer et quitter';

  @override
  String get clickToAddHeaderImage =>
      'Cliquer pour ajouter une image d\'en-tête';

  @override
  String get name => 'Nom';

  @override
  String get close => 'Fermer';

  @override
  String get dearUser => 'Cher utilisateur';

  @override
  String get paymentWorkInProgress =>
      'L\'intégration du paiement est en cours. Veuillez nous contacter directement pour finaliser votre achat.';

  @override
  String get paymentIntegrationMessage =>
      'Nous travaillons encore sur l\'intégration du paiement.\nNous nous excusons pour la gêne occasionnée. Nous reviendrons bientôt avec une meilleure solution. Merci de votre patience.';

  @override
  String get contactEmail => 'E-mail : abdoullouahd@gmail.com';

  @override
  String get contactPhone => 'Téléphone : +212628503463';

  @override
  String get thankYouForUnderstanding => 'Merci de votre compréhension !';

  @override
  String get amountDisplay => 'Montant : 299 MAD';

  @override
  String feesDisplay(String fees) {
    return 'Frais : $fees MAD';
  }

  @override
  String totalDisplay(String total) {
    return 'Total : $total MAD';
  }

  @override
  String paymentFailed(String error) {
    return 'Échec du paiement : $error';
  }

  @override
  String get unlockFullPotential => 'Débloquez tout le potentiel';

  @override
  String get fullAccessDescription =>
      'Accédez à toutes les fonctionnalités et générez des emplois du temps illimités.';

  @override
  String get getFullAccess =>
      'Accédez à votre emploi du temps sans restrictions.';

  @override
  String get premiumAccess => 'Accès Premium';

  @override
  String get perEightMonths => '/ 8 mois';

  @override
  String get featureRemoveLockedSlots => 'Supprimer les créneaux verrouillés';

  @override
  String get featureExportPdf => 'Exporter en PDF';

  @override
  String get featureAnyDevice => 'Accès sur n\'importe quel appareil';

  @override
  String get featureManualOverrides => 'Remplacements manuels';

  @override
  String get featurePrioritySupport => 'Support prioritaire';

  @override
  String get removeLockedSlots => 'Supprimer tous les créneaux verrouillés';

  @override
  String get exportPdf => 'Exporter l\'emploi du temps en PDF haute qualité';

  @override
  String get anyDevice =>
      'Accédez à votre emploi du temps sur n\'importe quel appareil';

  @override
  String get advancedOverrides => 'Remplacements manuels avancés';

  @override
  String get prioritySupport => 'Support client prioritaire';

  @override
  String get upgradeNow => 'Mettre à niveau maintenant';

  @override
  String get maybeLater => 'Peut-être plus tard';

  @override
  String get demoLimitTitle => 'Limite de la démo atteinte';

  @override
  String get demoLimitContent =>
      'La version démo ne prend en charge que les emplois du temps avec moins de 30 classes. Connectez-vous ou passez à la version Premium pour générer des emplois du temps avec 30 classes ou plus.';

  @override
  String get signInOrUpgrade => 'Se connecter / Mettre à niveau';

  @override
  String get segtimetableDescription =>
      'Une plateforme moderne pour gérer les emplois du temps scolaires avec simplicité et efficacité.';

  @override
  String get featureTimetablesTitle => 'Emplois du temps scolaires';

  @override
  String get featureTimetablesDesc =>
      'Créez et gérez facilement les emplois du temps scolaires.';

  @override
  String get featureSecureTitle => 'Sécurisé et fiable';

  @override
  String get featureSecureDesc =>
      'Vos informations sont protégées et stockées en toute sécurité.';

  @override
  String get featureSaveTimeTitle => 'Gagnez du temps';

  @override
  String get featureSaveTimeDesc =>
      'Organisez les emplois du temps plus rapidement grâce à un flux de travail simplifié.';

  @override
  String get featureSimpleTitle => 'Expérience simple';

  @override
  String get featureSimpleDesc =>
      'Une interface intuitive conçue pour tout le monde.';

  @override
  String get segtimetableQuote =>
      'Organiser les emplois du temps, pour mieux se concentrer sur l\'enseignement.';

  @override
  String get signInSubtitle =>
      'Bienvenue ! Veuillez vous connecter à votre compte.';

  @override
  String get signUpSubtitle =>
      'Créez votre compte en remplissant les informations ci-dessous.';

  @override
  String get requestTimedOut =>
      'La requête a pris trop de temps. Vérifiez votre connexion et réessayez.';

  @override
  String get unexpectedError => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get resetPasswordSuccess =>
      'Si un compte existe pour cet e-mail, un lien de réinitialisation a été envoyé.';

  @override
  String get warning => 'Avertissement';

  @override
  String get eraseSavedScheduleWarning =>
      'Générer un nouvel emploi du temps effacera celui enregistré.';

  @override
  String get impossibleToRecreate =>
      'Il est presque impossible de générer deux fois le même emploi du temps.';

  @override
  String get sureToContinue => 'Êtes-vous sûr de vouloir continuer ?';

  @override
  String get loadLastCreatedSchedule =>
      'Charger le dernier emploi du temps créé';

  @override
  String get pricing => 'Tarifs';

  @override
  String get aboutUs => 'À propos';

  @override
  String get exitCreator => 'Quitter le créateur';

  @override
  String get exitConfirmMessage =>
      'Êtes-vous sûr de vouloir quitter ? Vos modifications non enregistrées seront perdues.';

  @override
  String get exitBtn => 'Quitter';

  @override
  String get hintStartHour => 'ex. 8';

  @override
  String get hintEndHour => 'ex. 17';

  @override
  String get validationLevelNameRequired => 'Le nom du niveau est requis';

  @override
  String get validationLevelAlreadyExists => 'Ce niveau existe déjà';

  @override
  String get validationClassesRequired => 'Le nombre de classes est requis';

  @override
  String get labelLevelName => 'Nom du niveau';

  @override
  String get hintLevelName => 'ex. Primaire 1';

  @override
  String get labelNumberOfClasses => 'Nombre de classes';

  @override
  String get hintNumberOfClasses => 'ex. 3';

  @override
  String get validationSubjectNameRequired => 'Le nom de la matière est requis';

  @override
  String get validationSubjectAlreadyExists => 'La matière existe déjà';

  @override
  String get hintSubjectName => 'ex. Mathématiques';

  @override
  String get validationNonNegativeNumber => 'Entrez un nombre positif ou nul';

  @override
  String get validationCommaSeparatedNumbers =>
      'Entrez des nombres séparés par des virgules';

  @override
  String get subjectColor => 'Couleur de la matière';

  @override
  String get advancedParameters => 'Paramètres avancés';

  @override
  String get minimumRestHours => 'Heures minimales de repos';

  @override
  String get avoidHours => 'Heures à éviter';

  @override
  String get avoidHoursHint => 'Facultatif, ex. 1, 3, 5';

  @override
  String get validationRoomAlreadyExists => 'La salle existe déjà';

  @override
  String get hintRoomName => 'ex. Salle 101';

  @override
  String get validationNumberOfRoomsRequired =>
      'Le nombre de salles est requis';

  @override
  String get titleUpdateMinutes => 'Modifier les minutes';

  @override
  String get labelMinutes => 'Minutes';

  @override
  String get btnUpdate => 'Modifier';

  @override
  String get isNotScheduled => 'N\'est pas planifié';

  @override
  String lessThanNClasses(int count) {
    return 'Moins de $count classes';
  }

  @override
  String approxNStudents(int count) {
    return 'Environ $count élèves';
  }

  @override
  String get contactUsForAgreement => 'Contactez-nous pour un accord';

  @override
  String get titleSchoolBasic => 'Scolaire Basic';

  @override
  String get titleSchoolStandard => 'Scolaire Standard';

  @override
  String get titleSchoolPremium => 'Scolaire Premium';

  @override
  String get titleCustomAgreement => 'Sur Mesure';

  @override
  String get badgePopular => 'Populaire';

  @override
  String get priceAgreement => 'Sur devis';

  @override
  String get featureFlexibleClassCounts => 'Nombre de classes flexible';

  @override
  String get featureFlexibleStudentCounts => 'Nombre d\'élèves flexible';

  @override
  String get featureExamCorrection => 'Correction des examens';

  @override
  String get featureAbsenceManagement => 'Gestion des absences';

  @override
  String get featureLessonsPlanner => 'Planificateur de leçons';

  @override
  String get btnContactUs => 'Contactez-nous';

  @override
  String get licenseError => 'Erreur de licence';

  @override
  String get getALicense => 'Obtenir une licence';

  @override
  String get goHome => 'Aller à l\'accueil';

  @override
  String routeNotFound(String uri) {
    return 'Route non trouvée: $uri';
  }

  @override
  String get aboutHomeTooltip => 'Accueil';

  @override
  String get aboutAppBarTitle => 'À propos de Seg-Dude';

  @override
  String get aboutHeroChip => 'NOTRE HISTOIRE';

  @override
  String get aboutHeroTitle => 'À propos de Seg-Dude';

  @override
  String get aboutHeroSubtitle =>
      'Simplifier la gestion scolaire grâce à une technologie moderne et intelligente.';

  @override
  String get aboutScrollToExplore => 'Faites défiler pour explorer';

  @override
  String get aboutWhoWeAreChip => 'QUI SOMMES-NOUS';

  @override
  String get aboutWhoWeAreTitle => 'Qui sommes-nous';

  @override
  String get aboutWhoWeAreDescription =>
      'Seg-Dude est une plateforme moderne de gestion scolaire conçue pour simplifier le fonctionnement quotidien des établissements éducatifs. Notre objectif est d\'offrir une solution efficace, sécurisée et conviviale qui relie les administrateurs, les enseignants, les élèves et les parents à travers une expérience numérique intuitive.';

  @override
  String get aboutOurMissionTitle => 'Notre mission';

  @override
  String get aboutOurMissionDescription =>
      'Notre mission est de faciliter la gestion scolaire en proposant des outils numériques pratiques qui améliorent l\'organisation, simplifient la planification et favorisent un meilleur environnement éducatif pour les établissements.';

  @override
  String get aboutWhatWeOfferChip => 'CE QUE NOUS OFFRONS';

  @override
  String get aboutWhatWeOfferTitle => 'Ce que nous offrons';

  @override
  String get aboutFeatureTeacherManagementTitle => 'Gestion des enseignants';

  @override
  String get aboutFeatureTeacherManagementDesc =>
      'Organisez les profils, la disponibilité et la charge de travail des enseignants.';

  @override
  String get aboutFeatureClassSchedulingTitle => 'Planification des cours';

  @override
  String get aboutFeatureClassSchedulingDesc =>
      'Générez des emplois du temps sans conflit en quelques clics.';

  @override
  String get aboutFeatureSimpleInterfaceTitle => 'Interface simple et moderne';

  @override
  String get aboutFeatureSimpleInterfaceDesc =>
      'Une expérience claire conçue pour le personnel scolaire au quotidien.';

  @override
  String get aboutFeatureFastWorkflowTitle =>
      'Flux de travail rapide et organisé';

  @override
  String get aboutFeatureFastWorkflowDesc =>
      'Réduisez le travail manuel et centralisez toutes vos informations.';

  @override
  String get aboutComingSoonChip => 'BIENTÔT DISPONIBLE';

  @override
  String get aboutWhatsNextTitle => 'Prochaines étapes';

  @override
  String get aboutComingSoonIntro =>
      'Seg-Dude évolue en permanence. Voici un aperçu de ce que nous préparons.';

  @override
  String get aboutComingSoonFooter =>
      'Seg-Dude évolue en permanence. Nous travaillons sur de nouvelles fonctionnalités qui rendront la gestion scolaire encore plus intelligente et plus efficace.';

  @override
  String get aboutSoonBadge => 'Bientôt';

  @override
  String get aboutComingSoonStudentManagementTitle => 'Gestion des élèves';

  @override
  String get aboutComingSoonStudentManagementDesc =>
      'Profils et dossiers complets des élèves, centralisés en un seul endroit.';

  @override
  String get aboutComingSoonAttendanceTitle => 'Système de présence';

  @override
  String get aboutComingSoonAttendanceDesc =>
      'Suivez les présences et les absences en toute simplicité.';

  @override
  String get aboutComingSoonGradeManagementTitle => 'Gestion des notes';

  @override
  String get aboutComingSoonGradeManagementDesc =>
      'Enregistrez et analysez les performances des élèves.';

  @override
  String get aboutComingSoonParentPortalTitle => 'Portail parents';

  @override
  String get aboutComingSoonParentPortalDesc =>
      'Tenez les parents informés et impliqués.';

  @override
  String get aboutComingSoonNotificationsTitle => 'Notifications';

  @override
  String get aboutComingSoonNotificationsDesc =>
      'Alertes en temps utile pour le personnel, les élèves et les parents.';

  @override
  String get aboutComingSoonAiToolsTitle =>
      'Outils pédagogiques assistés par l\'IA';

  @override
  String get aboutComingSoonAiToolsDesc =>
      'Une assistance intelligente pour les tâches scolaires quotidiennes.';

  @override
  String get aboutOurVisionTitle => 'Notre vision';

  @override
  String get aboutOurVisionDescription =>
      'Nous envisageons un avenir où chaque établissement éducatif pourra gérer efficacement ses activités quotidiennes grâce à une technologie innovante qui fait gagner du temps, réduit la complexité et favorise la réussite scolaire.';

  @override
  String get aboutOurValuesChip => 'NOS VALEURS';

  @override
  String get aboutOurValuesTitle => 'Nos valeurs';

  @override
  String get aboutValueInnovationTitle => 'Innovation';

  @override
  String get aboutValueInnovationDesc =>
      'Apporter une technologie moderne aux besoins quotidiens des établissements scolaires.';

  @override
  String get aboutValueSimplicityTitle => 'Simplicité';

  @override
  String get aboutValueSimplicityDesc =>
      'Des outils intuitifs et faciles à utiliser.';

  @override
  String get aboutValueReliabilityTitle => 'Fiabilité';

  @override
  String get aboutValueReliabilityDesc =>
      'Des solutions sur lesquelles les établissements peuvent compter.';

  @override
  String get aboutValueSecurityTitle => 'Sécurité';

  @override
  String get aboutValueSecurityDesc =>
      'Protection des données scolaires et des élèves à chaque étape.';

  @override
  String get aboutStayConnectedChip => 'RESTEZ CONNECTÉS';

  @override
  String get aboutConnectWithUsTitle => 'Suivez nous';

  @override
  String get connectWithUsTitle => 'Connectez-vous avec nous';

  @override
  String get supportTitle => 'Soutien';

  @override
  String get supportSubtitle =>
      'Vous avez des questions ou besoin d\'aide ? Contactez-nous directement.';

  @override
  String get emailUs => 'Contactez-nous par email';

  @override
  String get sendUsEmailMessage =>
      'Envoyez-nous un e-mail et nous vous répondrons dans les plus brefs délais.';

  @override
  String get aboutConnectWithUsSubtitle =>
      'Suivez Seg-Dude pour des tutoriels, des mises à jour produit, des annonces et du nouveau contenu éducatif.';

  @override
  String get aboutYouTubePlatform => 'YouTube';

  @override
  String get aboutYouTubeActionLabel => 'Visiter la chaîne';

  @override
  String get aboutYouTubeDescription =>
      'Regardez des tutoriels, des présentations de fonctionnalités, des mises à jour et de futurs contenus vidéo.';

  @override
  String get aboutInstagramPlatform => 'Instagram';

  @override
  String get aboutInstagramActionLabel => 'Nous suivre';

  @override
  String get aboutInstagramDescription =>
      'Suivez-nous pour les actualités, les annonces, les coulisses et le contenu communautaire.';

  @override
  String get aboutCopyright => '© 2026 Seg-Dude. Tous droits réservés.';

  @override
  String get aboutBackToHome => 'Retour à l\'accueil';

  @override
  String get groups => 'Groupes';

  @override
  String get groupsAreAssignedToAClass =>
      'Les groupes sont assignés à une classe';

  @override
  String get groupsSplitClsIntoGroups => 'Split Class Into Groups';

  @override
  String get groupsSelectClassToSplit =>
      'Please select a class to split, click on the add button.';

  @override
  String get groupsAddSubjectFirst =>
      'Veuillez créer des matières en premier pour pouvoir diviser les classes';

  @override
  String get groupsAdd => 'Ajouter un groupe';

  @override
  String get groupsApplyToOthers => 'Appliquer aux autres classes';

  @override
  String get groupsApplyToOthersDesc =>
      'Voulez-vous appliquer la même contrainte à toutes les classes du même niveau?';

  @override
  String get groupsNotConf => 'Aucune configuration de groupe';

  @override
  String get groupsMerge => 'Fusionner les classes';

  @override
  String get groupsMergeClasses => 'Fusionner les classes en un groupe';

  @override
  String get groupsSelectClassesToMerge =>
      'Sélectionnez au moins deux classes de ce niveau.';

  @override
  String get groupsMergeWarningTitle => 'Groupes divisés trouvés';

  @override
  String get groupsMergeWarning =>
      'Certaines classes sélectionnées ont des groupes divisés pour cette matière. La fusion supprimera ces contraintes. Continuer?';

  @override
  String get groupsSelectTeacherFirstToMerge =>
      'Sélectionnez d\'abord un enseignant';

  @override
  String get groupsNoClassesForTeacherSubject =>
      'Aucune classe éligible pour cet enseignant et cette matière';

  @override
  String groupsClassesSelectedCount(int count) {
    return '$count classes sélectionnées';
  }

  @override
  String get groupsMergeSummary => 'Résumé';

  @override
  String get groupsMergeSuccessMessage => 'Classes fusionnées avec succès';

  @override
  String get groupsSelectSubjectToMerge =>
      'Choisissez la matière concernée par cette fusion';

  @override
  String get groupsSelectTeacherToMerge =>
      'Sélectionnez l\'enseignant responsable de cette matière';

  @override
  String get groupsNoTeacherAssignedForSubject =>
      'Aucun enseignant n\'est assigné à cette matière — vous pouvez tout de même fusionner ses classes';

  @override
  String get groupsNoTeacherAssignedShort => 'Aucun enseignant assigné';

  @override
  String get groupsNoQualifiedTeacherMergeBlocked =>
      'Aucun enseignant n\'est qualifié pour cette matière à ce niveau — la fusion n\'est pas disponible';

  @override
  String get deleteSubjectWarning =>
      'Les enseignants et les groupes associés à ce sujet seront également supprimés.';

  @override
  String get number => 'Nombre';

  @override
  String get id => 'Id';

  @override
  String get grouping => 'Regroupement';

  @override
  String get notes => 'Notes';

  @override
  String get noMatchingRecordsFound =>
      'Aucun résultat ne correspond aux critères de recherche.';

  @override
  String get supervisor => 'Superviseur';

  @override
  String get loadFromFile => 'Charger depuis fichier';

  @override
  String get noSavedScheduleFound => 'Aucun emploi du temps enregistré trouvé.';

  @override
  String get clickToCreateNewSchedule =>
      'Cliquez pour créer un nouvel emploi du temps';

  @override
  String get creationOptions => 'Options pour créer un nouvel emploi';

  @override
  String get chooseHowCreate =>
      'Choisissez comment créer un nouvel emploi du temps.';

  @override
  String get collapse => 'Masquer les listes';

  @override
  String get noGaps =>
      'Générer un emploi du temps sans lacunes (Priorité aux étudiants)';

  @override
  String get teacherBias =>
      'Générer un emploi du temps avec des groupes d\'enseignants (Priorité aux enseignants)';

  @override
  String get studFirst => 'Etudiant en premier';

  @override
  String get teacherFirst => 'Enseignant en premier';

  @override
  String get ifNoneSelected =>
      '(Si aucune class n\'est sélectionnée, alors toutes)';

  @override
  String get ifSubjetMultiTeachers =>
      'Si la matière compte plus d\'un enseignant, le système de périodes et de groupes est appliqué.';

  @override
  String get teachersCoexist =>
      'Les enseignants d\'une même matière peuvent être présentsà l\'école durant la même période.';

  @override
  String get licenseWarning =>
      'Les données peuvent être incorrectes sans licence premium';

  @override
  String get licenseWarningDesc =>
      'Veuillez obtenir une licence premium pour obtenir des données correctes.';

  @override
  String get schoolSeason => 'Saison scolaire';

  @override
  String get subjRequireRooms => 'La matière nécessite une salle';

  @override
  String get freeResourcesTabTitle => 'Ressources disponibles';

  @override
  String freeResourcesForLevel(String level) {
    return 'Ressources disponibles - Niveau $level';
  }

  @override
  String get freeClassesLabel => 'Classes libres';

  @override
  String get freeQualifiedTeachersLabel => 'Enseignants disponibles';

  @override
  String get freeRoomsLabel => 'Salles libres';

  @override
  String get noneLabel => 'Aucun';

  @override
  String get noFreeSlotsThisDay => 'Aucun créneau libre ce jour';

  @override
  String get noFreeSlotsAvailable => 'Aucun créneau libre disponible';

  @override
  String get freeForAllClasses => 'Tous les niveaux libres';

  @override
  String get freeForLevelClasses => 'Niveau entier libre';

  @override
  String get freeForSomeClasses => 'Quelques classes libres';

  @override
  String levelNumberFallback(String id) {
    return 'Niveau $id';
  }

  @override
  String get tapLevelForDetailsHint =>
      'Appuyez sur un niveau pour voir les enseignants et salles disponibles';

  @override
  String forcedSubjectInAllowedRooms(String subjectName, String roomName) {
    return 'La matière $subjectName est imposée dans une salle spécifique, mais elle apparaît dans les matières autorisées de $roomName. Continuer va retirer $subjectName des matières autorisées de $roomName.';
  }
}
