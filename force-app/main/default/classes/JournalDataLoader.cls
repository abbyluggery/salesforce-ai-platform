/**
 * JournalDataLoader
 *
 * Loads all 33 base journal products into Salesforce.
 * This is a one-time data loader for initial setup.
 *
 * Usage:
 *   JournalDataLoader.loadAllJournals();
 *
 * Part of the Journal Business module.
 */
public class JournalDataLoader {

    /**
     * Load all 33 base journals
     * Call this method once to initialize the journal catalog
     */
    public static void loadAllJournals() {
        List<Journal_Product__c> journals = new List<Journal_Product__c>();

        // Moon & Lunar Category (4 journals)
        journals.add(createJournal(
            'Beginner\'s Moon Journal',
            'Moon & Lunar',
            'A comprehensive guide for tracking lunar phases and moon rituals. Perfect for beginners exploring lunar magic.',
            'MOON-BEGIN',
            'MoonPhaseTracking,LunarRituals,BeginnerFriendly'
        ));

        journals.add(createJournal(
            'Moon Ritual Journal',
            'Moon & Lunar',
            'Deep dive into moon ritual practices with guided prompts for each lunar phase.',
            'MOON-RITUAL',
            'AdvancedRituals,LunarMagic,PhaseWork'
        ));

        journals.add(createJournal(
            'Manifestation Moon Journal',
            'Moon & Lunar',
            'Harness lunar energy for manifestation work. Align your goals with moon cycles.',
            'MOON-MANIFEST',
            'Manifestation,NewMoonWork,FullMoonReleasing'
        ));

        journals.add(createJournal(
            'Divination Moon Journal',
            'Moon & Lunar',
            'Track divination practices aligned with lunar phases for enhanced intuitive work.',
            'MOON-DIVINE',
            'Divination,Tarot,LunarIntuition'
        ));

        // Wellness & Mental Health Category (5 journals)
        journals.add(createJournal(
            'Mental Health Journal',
            'Wellness & Mental Health',
            'Daily mental health tracking with prompts for emotional awareness and self-care.',
            'WELLNESS-MENTAL',
            'MentalHealth,EmotionalWellness,DailyTracking'
        ));

        journals.add(createJournal(
            'Self-Care Journal',
            'Wellness & Mental Health',
            'Prioritize yourself with daily self-care prompts and wellness tracking.',
            'WELLNESS-SELFCARE',
            'SelfCare,Wellness,DailyRoutines'
        ));

        journals.add(createJournal(
            '365 Daily Affirmations Journal',
            'Wellness & Mental Health',
            'A full year of positive affirmations and gratitude prompts.',
            'WELLNESS-365',
            'Affirmations,Gratitude,YearLong'
        ));

        journals.add(createJournal(
            'Meal Planning Journal',
            'Wellness & Mental Health',
            'Weekly meal planning, grocery lists, and nutrition tracking.',
            'WELLNESS-MEAL',
            'MealPlanning,Nutrition,WeeklyPlanner'
        ));

        journals.add(createJournal(
            'Skin Care Journal',
            'Wellness & Mental Health',
            'Track your skincare routine, products, and skin health progress.',
            'WELLNESS-SKIN',
            'SkinCare,BeautyRoutine,ProductTracking'
        ));

        // Spiritual & Witchcraft Category (4 journals)
        journals.add(createJournal(
            'Spoonie Witch Journal',
            'Spiritual & Witchcraft',
            'Low-energy witchcraft for chronically ill practitioners. Gentle, accessible magic.',
            'WITCH-SPOONIE',
            'LowEnergyMagic,ChronicIllness,AccessibleWitchcraft'
        ));

        journals.add(createJournal(
            'Neurodivergent Witch Journal',
            'Spiritual & Witchcraft',
            'Witchcraft designed for ADHD, autism, and neurodivergent minds.',
            'WITCH-ND',
            'Neurodivergent,ADHDFriendly,AutismAccommodating'
        ));

        journals.add(createJournal(
            'Sacred Cycles Journal',
            'Spiritual & Witchcraft',
            'Track menstrual cycles, energy levels, and spiritual practice alignment.',
            'WITCH-CYCLES',
            'MenstrualMagic,CycleTracking,EnergyWork'
        ));

        journals.add(createJournal(
            'Lilith Shadow Work Journal',
            'Spiritual & Witchcraft',
            'Deep shadow work prompts exploring Lilith energy and reclaiming power.',
            'WITCH-LILITH',
            'ShadowWork,DarkFeminine,Empowerment'
        ));

        // LGBTQIA+ Category (3 journals)
        journals.add(createJournal(
            'Becoming Her - Trans Feminine Journey',
            'LGBTQIA+',
            'A journal for trans feminine individuals exploring identity, transition, and self-discovery.',
            'LGBTQ-TRANSFEM',
            'TransFeminine,TransitionJourney,GenderAffirming'
        ));

        journals.add(createJournal(
            'Claiming Him - Trans Masculine Journey',
            'LGBTQIA+',
            'A journal for trans masculine individuals claiming identity and authentic self.',
            'LGBTQ-TRANSMASC',
            'TransMasculine,TransitionJourney,GenderAffirming'
        ));

        journals.add(createJournal(
            'Rainbow Magic Journal',
            'LGBTQIA+',
            'LGBTQIA+ witchcraft and spiritual practice celebrating queer identity.',
            'LGBTQ-RAINBOW',
            'QueerWitchcraft,LGBTQSpirituality,PrideJourney'
        ));

        // Practical Life Category (8 journals)
        journals.add(createJournal(
            'Chore Planner',
            'Practical Life',
            'Weekly and monthly chore tracking for a clean, organized home.',
            'PRACTICAL-CHORE',
            'ChoreTracking,HomeOrganization,CleaningSchedule'
        ));

        journals.add(createJournal(
            'Home Maintenance Log',
            'Practical Life',
            'Track home repairs, maintenance schedules, and contractor information.',
            'PRACTICAL-MAINT',
            'HomeMaintenance,RepairLog,ContractorTracking'
        ));

        journals.add(createJournal(
            'Inventory Tracker',
            'Practical Life',
            'Household inventory for pantry, freezer, and storage organization.',
            'PRACTICAL-INVENTORY',
            'InventoryManagement,PantryTracking,StorageOrg'
        ));

        journals.add(createJournal(
            'Emergency Preparedness Guide',
            'Practical Life',
            'Emergency contacts, evacuation plans, and disaster prep checklists.',
            'PRACTICAL-EMERGENCY',
            'EmergencyPrep,DisasterPlanning,SafetyFirst'
        ));

        journals.add(createJournal(
            'Home Buying Journey',
            'Practical Life',
            'Track your home search, mortgage process, and moving checklist.',
            'PRACTICAL-HOMEBUYING',
            'HomeBuying,MortgageTracking,MovingPlanner'
        ));

        journals.add(createJournal(
            'Car Maintenance Log',
            'Practical Life',
            'Vehicle maintenance tracking, repair history, and mileage log.',
            'PRACTICAL-CAR',
            'CarMaintenance,VehicleLog,RepairHistory'
        ));

        journals.add(createJournal(
            'Perimenopause Journal',
            'Practical Life',
            'Track symptoms, hormones, and wellness during perimenopause transition.',
            'PRACTICAL-PERI',
            'Perimenopause,HormoneTracking,SymptomLog'
        ));

        journals.add(createJournal(
            'Gym Workout Tracker',
            'Practical Life',
            'Log workouts, track progress, and plan fitness goals.',
            'PRACTICAL-GYM',
            'WorkoutLog,FitnessTracking,GymPlanner'
        ));

        // Garden & Homestead Category (5 journals)
        journals.add(createJournal(
            'Garden Planner',
            'Garden & Homestead',
            'Plan your garden layout, planting schedule, and harvest tracking.',
            'GARDEN-PLANNER',
            'GardenPlanning,PlantingSchedule,HarvestLog'
        ));

        journals.add(createJournal(
            'Garden Inventory',
            'Garden & Homestead',
            'Track seeds, tools, supplies, and garden equipment.',
            'GARDEN-INVENTORY',
            'SeedInventory,ToolTracking,SupplyManagement'
        ));

        journals.add(createJournal(
            'Gardening Journal',
            'Garden & Homestead',
            'Daily gardening notes, weather tracking, and plant observations.',
            'GARDEN-JOURNAL',
            'DailyGardening,WeatherLog,PlantNotes'
        ));

        journals.add(createJournal(
            'Crop Log',
            'Garden & Homestead',
            'Track crop yields, varieties, and yearly comparisons.',
            'GARDEN-CROP',
            'CropYields,VarietyTracking,HarvestData'
        ));

        journals.add(createJournal(
            'Foraging Journal',
            'Garden & Homestead',
            'Track foraging locations, seasonal finds, and wild edibles.',
            'GARDEN-FORAGE',
            'Foraging,WildEdibles,SeasonalHarvest'
        ));

        // Fitness & Wellness Category (4 journals)
        journals.add(createJournal(
            'Fitness Goal Tracker',
            'Fitness & Wellness',
            'Set and track fitness goals with progress monitoring and motivation.',
            'FITNESS-GOALS',
            'FitnessGoals,ProgressTracking,Motivation'
        ));

        journals.add(createJournal(
            'Workout Log',
            'Fitness & Wellness',
            'Detailed workout logging with exercises, sets, reps, and weights.',
            'FITNESS-WORKOUT',
            'WorkoutTracking,ExerciseLog,StrengthTraining'
        ));

        journals.add(createJournal(
            'Nutrition Tracker',
            'Fitness & Wellness',
            'Track meals, macros, and nutrition goals for optimal health.',
            'FITNESS-NUTRITION',
            'NutritionTracking,MacroCounting,MealLog'
        ));

        journals.add(createJournal(
            'Wellness Habits Journal',
            'Fitness & Wellness',
            'Build healthy habits with daily tracking and accountability.',
            'FITNESS-HABITS',
            'HabitTracking,DailyWellness,Accountability'
        ));

        // Insert all 33 journals
        try {
            insert journals;
            System.debug('Successfully loaded ' + journals.size() + ' journals');
        } catch (DmlException e) {
            System.debug('Error loading journals: ' + e.getMessage());
            throw e;
        }
    }

    /**
     * Helper method to create a journal product record
     */
    private static Journal_Product__c createJournal(
        String name,
        String category,
        String description,
        String baseCode,
        String features
    ) {
        return new Journal_Product__c(
            Name = name,
            Parent_Journal_Name__c = name,
            Category__c = category,
            Description__c = description,
            Key_Features__c = features,
            // These will be updated when SKU variations are created
            Product_SKU__c = baseCode + '-BASE',
            Trim_Size__c = '6x9',
            Binding_Type__c = 'Perfect Bound',
            Product_Tier__c = 'Standard',
            Page_Count__c = 400,
            Base_Price__c = 24.99,
            Is_Condensed_Version__c = false,
            Paper_Color__c = 'White',
            Paper_Weight__c = '60#',
            Cover_Material__c = 'Matte Paper',
            Foil_Stamp_Color__c = 'None',
            Has_Ribbon_Bookmark__c = false
        );
    }
}
