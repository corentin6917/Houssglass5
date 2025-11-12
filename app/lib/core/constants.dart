/// Core constants for the Hourglass application
library;

// Grain mechanics
const int kDailyGrainsPotential = 10;
const double kBoostCost = 0.2;
const double kTransfusionAmount = 1.0;
const double kCommentCost = 0.1;

// Timings (UTC hours for Europe/Paris timezone)
const int kMorningContractHour = 8;
const int kEveningSyncHour = 20;

// Feed visibility
const Duration kFeedVisibilityDuration = Duration(hours: 24);
const Duration kProofExpirationDuration = Duration(hours: 24);

// Devaluation phases (days)
const Map<String, double> kDevaluationPhases = {
  'phase1': 1.0,    // Days 1-30: 100%
  'phase2': 0.8,    // Days 31-90: 80%
  'phase3': 0.6,    // Days 91-180: 60%
  'phase4': 0.5,    // Days 181+: 50% (floor)
};

// Phoenix mode triggers
const int kPhoenixLowGrainThreshold = 3;
const int kPhoenixLowGrainDays = 14;
const double kPhoenixRatioDropPercent = 10.0;
const int kPhoenixNoVictoryDays = 14;
const double kPhoenixMultiplier = 3.0;
const int kPhoenixMinimumGrains = 1;

// Seasons thresholds (average grains per day over 30 days)
const double kSeasonWinterThreshold = 4.0;
const double kSeasonSpringThreshold = 5.0;
const double kSeasonSummerThreshold = 7.0;

// Capsule frequency
const int kCapsuleDayInterval = 100;

// UI
const double kAnimationDuration = 0.3;
const double kHourglassAspectRatio = 0.6;
