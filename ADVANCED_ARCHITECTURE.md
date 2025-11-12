# HOURGLASS - Architecture Avancée 🚀

## Vision : Application de Nouvelle Génération

Transformer HOURGLASS d'un MVP simple en une **plateforme intelligente, immersive et scalable** qui révolutionne la façon dont les utilisateurs suivent leurs victoires quotidiennes.

---

## 🎯 Objectifs de la Refonte

### 1. Intelligence Artificielle & Machine Learning
- Prédiction comportementale des utilisateurs
- Recommandations personnalisées d'objectifs
- Détection automatique des patterns de succès/échec
- Analyse de sentiment sur les victoires

### 2. Gamification Avancée
- Système de progression multi-niveaux
- Achievements déblocables
- Défis communautaires
- Événements saisonniers

### 3. Expérience Utilisateur Immersive
- Animations 3D pour le sablier
- Effets de particules pour les grains
- Haptic feedback intelligent
- Son ambiant adaptatif
- Mode AR (Augmented Reality) pour capturer les preuves

### 4. Architecture Scalable
- Microservices
- Event-driven architecture
- Caching multi-niveaux
- CDN pour les assets
- WebSockets en temps réel

### 5. Analytics & Insights Profonds
- Dashboard personnel avec statistiques avancées
- Graphiques interactifs
- Comparaisons temporelles
- Insights prédictifs

---

## 🏗️ Nouvelle Architecture Système

```
┌─────────────────────────────────────────────────────────────────┐
│                        Client Layer                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Flutter App (Mobile + Web + Desktop)                    │  │
│  │  • Riverpod 2.0 (State Management)                       │  │
│  │  • Flutter Animate (Animations avancées)                 │  │
│  │  • Rive (Animations vectorielles)                        │  │
│  │  • Flame Engine (Physique des grains)                    │  │
│  │  • AR Core / AR Kit (Capture AR)                         │  │
│  │  • Audio Players (Sons immersifs)                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            │ GraphQL / WebSocket
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                        API Gateway                               │
│  • Rate Limiting                                                 │
│  • Authentication (JWT + OAuth2)                                 │
│  • Request Routing                                               │
│  • Load Balancing                                                │
└───────────────────────────┬─────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        ↓                   ↓                   ↓
┌───────────────┐  ┌────────────────┐  ┌──────────────────┐
│ User Service  │  │ Goals Service  │  │ Social Service   │
│ (FastAPI)     │  │ (FastAPI)      │  │ (FastAPI)        │
└───────┬───────┘  └────────┬───────┘  └────────┬─────────┘
        │                   │                    │
        └───────────────────┼────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                     Intelligence Layer                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AI/ML Services (Python + TensorFlow/PyTorch)            │  │
│  │  • Goal Recommendation Engine                            │  │
│  │  • Behavior Prediction Model                             │  │
│  │  • Image Recognition (Proof validation)                  │  │
│  │  • NLP for Goal Analysis                                 │  │
│  │  • Sentiment Analysis                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ PostgreSQL   │  │ Redis Cache  │  │ TimescaleDB  │         │
│  │ (Supabase)   │  │ (Sessions)   │  │ (Analytics)  │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ S3 Storage   │  │ Elasticsearch│  │ ClickHouse   │         │
│  │ (Media)      │  │ (Search)     │  │ (Events)     │         │
│  └──────────────┘  └──────────────┘  └──────────────┘         │
└─────────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Background Services                           │
│  • Celery Workers (Async tasks)                                 │
│  • Apache Kafka (Event streaming)                               │
│  • Airflow (Data pipelines)                                     │
│  • Cron Jobs (Scheduled tasks)                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🧠 Intelligence Artificielle - Détail

### 1. Goal Recommendation Engine

**Technologie:** TensorFlow / Scikit-learn

**Fonctionnalités:**
```python
class GoalRecommender:
    def __init__(self):
        self.model = load_collaborative_filtering_model()
        self.user_embeddings = {}
        self.goal_embeddings = {}

    def recommend_goals(self, user_id: str, context: dict) -> List[Goal]:
        """
        Recommande des objectifs basés sur:
        - Historique personnel
        - Objectifs similaires d'autres utilisateurs
        - Contexte temporel (jour de la semaine, saison)
        - Taux de succès historique
        - Préférences explicites
        """
        user_vector = self.get_user_embedding(user_id)
        context_vector = self.encode_context(context)

        # Collaborative filtering + Content-based
        similar_users = self.find_similar_users(user_vector)
        popular_goals = self.get_trending_goals(similar_users)

        # Filtrage par taux de réussite prédit
        achievable_goals = self.filter_by_predicted_success(
            popular_goals,
            user_id,
            threshold=0.6
        )

        return achievable_goals[:10]

    def predict_success_probability(self, user_id: str, goal: Goal) -> float:
        """
        Prédit la probabilité de succès d'un objectif pour un utilisateur
        """
        features = self.extract_features(user_id, goal)
        return self.model.predict_proba(features)[0][1]
```

### 2. Behavior Prediction Model

**Technologie:** LSTM (Long Short-Term Memory) Neural Networks

**Prédictions:**
- Risque d'abandon dans les 7 prochains jours
- Meilleur moment pour envoyer des notifications
- Probabilité de compléter un objectif donné
- Détection précoce du besoin de Phoenix Mode

```python
class BehaviorPredictor:
    def __init__(self):
        self.lstm_model = load_lstm_model()
        self.sequence_length = 30  # 30 jours d'historique

    def predict_churn_risk(self, user_id: str) -> float:
        """
        Analyse les 30 derniers jours pour prédire le risque d'abandon
        """
        sequence = self.get_user_sequence(user_id, days=30)
        features = self.engineer_features(sequence)
        return self.lstm_model.predict(features)[0]

    def optimal_notification_time(self, user_id: str) -> datetime:
        """
        Trouve le meilleur moment pour envoyer une notification
        basé sur l'historique d'engagement
        """
        engagement_history = self.get_engagement_patterns(user_id)
        return self.find_peak_engagement_time(engagement_history)
```

### 3. Image Recognition (Proof Validation)

**Technologie:** Vision Transformer (ViT) / CLIP

**Fonctionnalités:**
- Validation automatique des preuves photos
- Détection de la pertinence photo/objectif
- Génération de tags automatiques
- Détection de duplicatas/fraudes

```python
class ProofValidator:
    def __init__(self):
        self.vision_model = load_clip_model()
        self.nsfw_detector = load_nsfw_model()

    async def validate_proof(self, image: bytes, goal_text: str) -> ValidationResult:
        """
        Valide qu'une image correspond bien à un objectif
        """
        # Détection NSFW
        if self.nsfw_detector.predict(image) > 0.5:
            return ValidationResult(valid=False, reason="inappropriate_content")

        # Correspondance image/texte
        image_embedding = self.vision_model.encode_image(image)
        text_embedding = self.vision_model.encode_text(goal_text)

        similarity = cosine_similarity(image_embedding, text_embedding)

        if similarity > 0.7:
            tags = self.generate_tags(image)
            return ValidationResult(
                valid=True,
                confidence=similarity,
                auto_tags=tags
            )
        else:
            return ValidationResult(
                valid=False,
                reason="image_goal_mismatch",
                suggestion="La photo ne semble pas correspondre à l'objectif"
            )
```

### 4. NLP pour Goal Analysis

**Technologie:** BERT / GPT-4

**Fonctionnalités:**
- Extraction automatique de mots-clés
- Catégorisation intelligente des objectifs
- Suggestion de reformulation pour meilleur succès
- Détection de l'ambiguïté

```python
class GoalAnalyzer:
    def __init__(self):
        self.nlp_model = load_bert_model()
        self.gpt = OpenAIClient()

    def analyze_goal(self, goal_text: str) -> GoalAnalysis:
        """
        Analyse complète d'un objectif
        """
        # Extraction d'entités
        entities = self.extract_entities(goal_text)

        # Catégorisation
        category = self.categorize(goal_text)

        # Évaluation de la clarté
        clarity_score = self.evaluate_clarity(goal_text)

        # Suggestions d'amélioration
        suggestions = []
        if clarity_score < 0.7:
            suggestions = self.gpt.suggest_improvements(goal_text)

        return GoalAnalysis(
            entities=entities,
            category=category,
            clarity_score=clarity_score,
            suggestions=suggestions,
            estimated_difficulty=self.estimate_difficulty(goal_text)
        )
```

---

## 🎮 Gamification Avancée

### 1. Système de Niveaux & XP

```typescript
interface UserLevel {
  level: number;
  xp: number;
  xp_to_next_level: number;
  title: string;  // "Apprenti", "Alchimiste", "Maître du Temps"
  perks: Perk[];
}

interface Perk {
  id: string;
  name: string;
  description: string;
  effect: PerkEffect;
}

enum PerkEffect {
  EXTRA_DAILY_GRAIN = "extra_daily_grain",  // +1 grain quotidien
  BOOST_DISCOUNT = "boost_discount",        // Boosts coûtent -20%
  PHOENIX_PROTECTION = "phoenix_protection", // 1 échec pardonné/semaine
  VISION_UNLOCK = "vision_unlock",          // Voir les stats des autres
}

class LevelingSystem {
  calculate_xp_gain(action: Action): number {
    const xp_map = {
      'complete_goal': 100,
      'complete_streak_3': 150,
      'complete_streak_7': 500,
      'send_boost': 20,
      'receive_transfusion': 50,
      'upload_proof': 30,
      'reach_new_season': 1000,
    };
    return xp_map[action.type] * action.multiplier;
  }

  apply_xp_gain(user_id: string, xp: number): LevelUpResult {
    // Logique de montée de niveau avec rewards
  }
}
```

### 2. Achievements System

```typescript
interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  reward: Reward;
  conditions: Condition[];
  progress: number;
  unlocked: boolean;
}

const ACHIEVEMENTS: Achievement[] = [
  {
    id: 'first_steps',
    name: 'Premiers Pas',
    description: 'Complète ton premier objectif',
    rarity: 'common',
    reward: { xp: 100, golden_grains: 5 },
    conditions: [{ type: 'goals_completed', value: 1 }]
  },
  {
    id: 'perfect_week',
    name: 'Semaine Parfaite',
    description: 'Complète tous tes objectifs pendant 7 jours consécutifs',
    rarity: 'epic',
    reward: { xp: 1000, golden_grains: 50, perk: 'PHOENIX_PROTECTION' },
    conditions: [
      { type: 'perfect_days_streak', value: 7 }
    ]
  },
  {
    id: 'phoenix_master',
    name: 'Maître du Phoenix',
    description: 'Sors du Phoenix Mode 3 fois',
    rarity: 'legendary',
    reward: { xp: 2000, golden_grains: 100, cosmetic: 'phoenix_aura' },
    conditions: [
      { type: 'phoenix_exits', value: 3 }
    ]
  },
  // ... 50+ achievements
];
```

### 3. Défis Communautaires

```typescript
interface CommunityChallenge {
  id: string;
  title: string;
  description: string;
  start_date: Date;
  end_date: Date;
  goal_type: 'collective' | 'competitive';
  target_value: number;  // Ex: 10000 grains collectifs
  current_value: number;
  participants: number;
  rewards: Reward[];
  leaderboard: LeaderboardEntry[];
}

// Exemple: "Défi du Millénaire"
const challenge: CommunityChallenge = {
  id: 'millennium_challenge',
  title: 'Défi du Millénaire',
  description: 'La communauté doit collecter 1 million de grains en 30 jours',
  goal_type: 'collective',
  target_value: 1000000,
  rewards: [
    { all_participants: { xp: 500, golden_grains: 20 } },
    { top_100: { xp: 1000, golden_grains: 50, badge: 'millennium_hero' } }
  ]
};
```

### 4. Événements Saisonniers

```typescript
interface SeasonalEvent {
  id: string;
  name: string;
  theme: string;
  start_date: Date;
  end_date: Date;
  special_mechanics: Mechanic[];
  exclusive_rewards: Reward[];
  limited_cosmetics: Cosmetic[];
}

// Exemple: Événement "Phoenix Rising" (Mars)
const phoenixRisingEvent: SeasonalEvent = {
  id: 'phoenix_rising_2025',
  name: 'Phoenix Rising',
  theme: 'Renouveau de Printemps',
  special_mechanics: [
    {
      type: 'double_xp_phoenix_mode',
      description: 'XP doublé en Phoenix Mode pendant l\'événement'
    },
    {
      type: 'phoenix_eggs',
      description: 'Des "oeufs de phoenix" apparaissent aléatoirement, contenant des rewards'
    }
  ],
  exclusive_rewards: [
    { type: 'cosmetic', name: 'Phoenix Wings Aura', rarity: 'legendary' }
  ]
};
```

---

## 🎨 Expérience Utilisateur Immersive

### 1. Animations 3D du Sablier

**Technologie:** Rive + Flame Engine

```dart
class HourglassWidget extends StatefulWidget {
  @override
  _HourglassWidgetState createState() => _HourglassWidgetState();
}

class _HourglassWidgetState extends State<HourglassWidget>
    with TickerProviderStateMixin {
  late FlameGame game;
  late AnimationController rotationController;

  @override
  void initState() {
    super.initState();

    // Physique réaliste pour les grains
    game = GrainPhysicsGame(
      grainCount: widget.goldenGrains,
      gravity: Vector2(0, 980),  // Gravité réaliste
      particleSystem: ParticleSystemConfig(
        sparkle: true,
        glow: true,
        trail: true
      )
    );

    // Animation de rotation du sablier
    rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
  }

  void onGrainEarned(int newGrains) {
    // Animation de descente grain par grain
    for (int i = 0; i < newGrains; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        game.addGrain(
          position: Vector2(centerX, topY),
          color: Color(0xFFFFD700),
          properties: GrainProperties(
            mass: 1.0,
            bounciness: 0.3,
            friction: 0.8,
            glow: true
          )
        );

        // Son de grain qui tombe
        AudioPlayer().play('assets/sounds/grain_drop.mp3');

        // Haptic feedback
        HapticFeedback.lightImpact();
      });
    }
  }
}

class GrainPhysicsGame extends FlameGame {
  final Forge2DComponent physics;
  List<Grain> grains = [];

  void addGrain(Vector2 position, Color color, GrainProperties props) {
    final grain = Grain(
      position: position,
      color: color,
      properties: props
    );

    // Ajout de trainée de particules
    add(TrailParticles(
      follow: grain,
      color: color.withOpacity(0.5),
      lifetime: 0.5
    ));

    grains.add(grain);
    add(grain);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Détection de collision entre grains
    for (var i = 0; i < grains.length; i++) {
      for (var j = i + 1; j < grains.length; j++) {
        if (grains[i].collidesWith(grains[j])) {
          handleCollision(grains[i], grains[j]);
        }
      }
    }
  }
}
```

### 2. Effets Visuels Avancés

```dart
class VictoryFeedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: FlutterAnimate(
        effects: [
          FadeEffect(duration: 300.ms),
          ScaleEffect(begin: Offset(0.8, 0.8), duration: 300.ms),
          ShimmerEffect(  // Effet de brillance
            duration: 2000.ms,
            colors: [
              Colors.transparent,
              AppColors.goldenGrain.withOpacity(0.5),
              Colors.transparent
            ]
          ),
          TiltEffect(  // Effet de parallaxe au scroll
            begin: Offset(0, 0),
            end: Offset(0.1, 0.1)
          )
        ],
        child: Stack(
          children: [
            // Particules dorées en background
            Positioned.fill(
              child: ParticleField(
                particleCount: 20,
                particleColor: AppColors.goldenGrain,
                animationDuration: Duration(seconds: 5),
                particleSize: 2.0,
              ),
            ),
            // Contenu de la carte
            VictoryContent(item: widget.item),
            // Badge "NEW" avec glow
            if (widget.item.isNew)
              Positioned(
                top: 10,
                right: 10,
                child: GlowingBadge(text: 'NEW'),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Mode AR (Augmented Reality)

```dart
class ARProofCapture extends StatefulWidget {
  @override
  _ARProofCaptureState createState() => _ARProofCaptureState();
}

class _ARProofCaptureState extends State<ARProofCapture> {
  late ARSessionManager arSessionManager;
  late ARObjectManager arObjectManager;

  @override
  void initState() {
    super.initState();
    arSessionManager = ARSessionManager();
  }

  @override
  Widget build(BuildContext context) {
    return ARView(
      onARViewCreated: onARViewCreated,
      planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
    );
  }

  void onARViewCreated(ARSessionManager sessionManager,
                       ARObjectManager objectManager) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;

    // Détection de plans
    arSessionManager.onPlaneDetected = (plane) {
      // Afficher l'hologramme du sablier sur le plan détecté
      showHourglassHologram(plane);
    };
  }

  void showHourglassHologram(ARPlane plane) {
    final hologram = ARNode(
      type: ARNodeType.glb,
      uri: 'assets/models/hourglass_hologram.glb',
      scale: Vector3(0.1, 0.1, 0.1),
      position: plane.centerPosition,
      rotation: Vector4(0, 1, 0, 0),
      animations: ['idle', 'fill_grain', 'rotate']
    );

    // Animation de remplissage en temps réel
    hologram.playAnimation('fill_grain');

    arObjectManager.addNode(hologram);
  }

  void captureARProof() async {
    // Capture d'écran AR
    final screenshot = await arSessionManager.snapshot();

    // Ajout d'overlay avec timestamp et géolocalisation
    final enhancedImage = await addProofOverlay(
      screenshot,
      timestamp: DateTime.now(),
      location: await getCurrentLocation(),
      goalText: widget.goalText
    );

    // Upload avec metadata
    await uploadProof(enhancedImage);
  }
}
```

### 4. Son Ambiant Adaptatif

```dart
class AdaptiveAudioManager {
  late AudioPlayer musicPlayer;
  late AudioPlayer sfxPlayer;

  final Map<UserState, String> soundtracks = {
    UserState.morning: 'assets/audio/morning_calm.mp3',
    UserState.active: 'assets/audio/focused_energy.mp3',
    UserState.phoenix: 'assets/audio/phoenix_rising.mp3',
    UserState.victory: 'assets/audio/victory_celebration.mp3',
    UserState.winter: 'assets/audio/winter_contemplation.mp3',
    UserState.summer: 'assets/audio/summer_triumph.mp3',
  };

  void updateAmbiance(UserState state, double lifeRatio) {
    // Transition douce entre ambiances
    final newTrack = soundtracks[state];
    musicPlayer.crossFade(
      to: newTrack,
      duration: Duration(seconds: 3),
      curve: Curves.easeInOut
    );

    // Ajuster le pitch en fonction du ratio de vie
    // Ratio élevé = sons plus aigus et joyeux
    final pitch = 0.8 + (lifeRatio / 10.0) * 0.4;
    musicPlayer.setPitch(pitch);

    // Sons ambiants additionnels
    if (state == UserState.phoenix) {
      // Sons de feu crépitant
      sfxPlayer.playLooped('assets/audio/fire_crackle.mp3', volume: 0.3);
    }
  }

  void playSFX(SFXType type) {
    final sfxMap = {
      SFXType.grainDrop: 'assets/audio/grain_drop.mp3',
      SFXType.grainEarn: 'assets/audio/grain_earn.mp3',
      SFXType.grainEvaporate: 'assets/audio/grain_evaporate.mp3',
      SFXType.levelUp: 'assets/audio/level_up.mp3',
      SFXType.achievementUnlock: 'assets/audio/achievement.mp3',
      SFXType.boostSent: 'assets/audio/boost_whoosh.mp3',
      SFXType.transfusion: 'assets/audio/transfusion_magic.mp3',
    };

    sfxPlayer.play(sfxMap[type], volume: 0.7);
  }
}
```

---

## 📊 Analytics & Insights Avancés

### 1. Dashboard Personnel

```dart
class AnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Graphique de progression sur 90 jours
        TimeSeriesChart(
          data: userStats.last90Days,
          metrics: [
            Metric.grainsEarned,
            Metric.grainsEvaporated,
            Metric.lifeRatio
          ],
          interactive: true,
          zoomable: true,
        ),

        // Heatmap des jours de succès
        CalendarHeatmap(
          data: userStats.dailyPerformance,
          colorScale: [
            Colors.grey[300],  // 0 grains
            Colors.amber[200], // 1-3 grains
            Colors.amber[500], // 4-7 grains
            AppColors.goldenGrain, // 8-10 grains
          ],
        ),

        // Radar chart des catégories d'objectifs
        RadarChart(
          categories: userStats.goalCategories,
          metrics: [
            'Taux de succès',
            'Fréquence',
            'Valeur moyenne',
            'Streak max'
          ],
        ),

        // Insights prédictifs
        InsightsPanel(
          insights: [
            Insight(
              type: InsightType.prediction,
              title: 'Prédiction pour demain',
              content: 'Tu as 87% de chances de compléter tes objectifs demain 🎯',
              confidence: 0.87
            ),
            Insight(
              type: InsightType.recommendation,
              title: 'Meilleur moment',
              content: 'Tu réussis mieux les objectifs sportifs le matin vers 8h',
              action: 'Programmer rappel',
            ),
            Insight(
              type: InsightType.warning,
              title: 'Attention',
              content: 'Risque d\'entrer en Phoenix Mode dans 5 jours si tu ne t\'améliores pas',
              severity: SeverityLevel.medium
            )
          ],
        ),

        // Comparaison avec soi-même dans le passé
        SelfComparisonCard(
          current: userStats.currentPeriod,
          previous: userStats.previousPeriod,
          metrics: [
            'Grains moyens/jour',
            'Taux de succès',
            'Streak max',
            'Ratio de vie'
          ],
        ),
      ],
    );
  }
}
```

### 2. Système de Tags Intelligents

```python
class IntelligentTagging:
    def __init__(self):
        self.tag_model = load_tag_model()
        self.graph_db = Neo4jClient()  # Graph database pour relations

    async def tag_goal(self, goal: Goal) -> List[Tag]:
        """
        Génère des tags multi-niveaux pour un objectif
        """
        # Tags explicites (keywords)
        explicit_tags = self.extract_keywords(goal.text)

        # Tags implicites (ML)
        implicit_tags = self.tag_model.predict(goal.text)

        # Tags contextuels
        contextual_tags = self.get_contextual_tags(
            time_of_day=goal.created_at.hour,
            day_of_week=goal.created_at.weekday(),
            season=goal.season
        )

        # Tags de difficulté prédite
        difficulty_tag = self.predict_difficulty_tag(goal)

        # Tags de catégorie hiérarchique
        hierarchical_tags = self.categorize_hierarchically(goal)
        # Ex: ["Sport", "Sport.Cardio", "Sport.Cardio.Course"]

        all_tags = (explicit_tags + implicit_tags +
                   contextual_tags + [difficulty_tag] + hierarchical_tags)

        # Stocker dans graph DB pour recommandations
        await self.graph_db.store_goal_tags(goal.id, all_tags)

        return all_tags

    async def find_similar_goals(self, goal_id: str, limit: int = 10) -> List[Goal]:
        """
        Trouve des objectifs similaires via le graph
        """
        query = """
        MATCH (g1:Goal {id: $goal_id})-[:TAGGED_WITH]->(t:Tag)<-[:TAGGED_WITH]-(g2:Goal)
        WHERE g1 <> g2
        WITH g2, count(t) as common_tags
        ORDER BY common_tags DESC
        LIMIT $limit
        RETURN g2
        """
        return await self.graph_db.query(query, goal_id=goal_id, limit=limit)
```

---

## 🔄 Architecture Event-Driven

### 1. Event Bus avec Kafka

```python
from kafka import KafkaProducer, KafkaConsumer
import asyncio

class EventBus:
    def __init__(self):
        self.producer = KafkaProducer(
            bootstrap_servers=['localhost:9092'],
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )
        self.consumers = {}

    async def publish(self, event_type: str, payload: dict):
        """
        Publie un événement sur le bus
        """
        event = {
            'type': event_type,
            'timestamp': datetime.now().isoformat(),
            'payload': payload,
            'version': '1.0'
        }

        self.producer.send(f'hourglass.{event_type}', event)
        self.producer.flush()

    async def subscribe(self, event_type: str, handler: Callable):
        """
        Souscrit à un type d'événement
        """
        consumer = KafkaConsumer(
            f'hourglass.{event_type}',
            bootstrap_servers=['localhost:9092'],
            value_deserializer=lambda m: json.loads(m.decode('utf-8'))
        )

        self.consumers[event_type] = consumer

        # Process events asynchronously
        while True:
            for message in consumer:
                await handler(message.value)

# Types d'événements
class EventType:
    GOAL_CREATED = 'goal.created'
    GOAL_COMPLETED = 'goal.completed'
    GOAL_FAILED = 'goal.failed'
    GRAIN_EARNED = 'grain.earned'
    GRAIN_EVAPORATED = 'grain.evaporated'
    LEVEL_UP = 'user.level_up'
    ACHIEVEMENT_UNLOCKED = 'achievement.unlocked'
    PHOENIX_ENTERED = 'phoenix.entered'
    PHOENIX_EXITED = 'phoenix.exited'
    SEASON_CHANGED = 'season.changed'
    BOOST_SENT = 'social.boost_sent'
    TRANSFUSION_SENT = 'social.transfusion_sent'
    CHALLENGE_JOINED = 'challenge.joined'
    CHALLENGE_COMPLETED = 'challenge.completed'

# Exemple d'utilisation
event_bus = EventBus()

@event_bus.subscribe(EventType.GOAL_COMPLETED)
async def on_goal_completed(event):
    user_id = event['payload']['user_id']
    goal_id = event['payload']['goal_id']

    # Déclencher plusieurs actions en parallèle
    await asyncio.gather(
        update_user_stats(user_id),
        check_achievements(user_id),
        update_leaderboard(user_id),
        send_notification(user_id, 'Objectif complété!'),
        trigger_ml_update(user_id, goal_id)
    )
```

### 2. Microservices Architecture

```yaml
# docker-compose.yml
version: '3.8'

services:
  # API Gateway
  api-gateway:
    image: kong:latest
    ports:
      - "8000:8000"
      - "8001:8001"
    environment:
      KONG_DATABASE: postgres
    depends_on:
      - postgres

  # User Service
  user-service:
    build: ./services/user
    ports:
      - "8001:8000"
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/users
      REDIS_URL: redis://redis:6379

  # Goals Service
  goals-service:
    build: ./services/goals
    ports:
      - "8002:8000"
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/goals
      KAFKA_BROKERS: kafka:9092

  # Social Service
  social-service:
    build: ./services/social
    ports:
      - "8003:8000"
    environment:
      DATABASE_URL: postgresql://user:pass@postgres:5432/social
      KAFKA_BROKERS: kafka:9092

  # AI/ML Service
  ml-service:
    build: ./services/ml
    ports:
      - "8004:8000"
    environment:
      MODEL_PATH: /models
      TENSORFLOW_SERVING_URL: tensorflow-serving:8501
    volumes:
      - ./models:/models

  # Analytics Service
  analytics-service:
    build: ./services/analytics
    ports:
      - "8005:8000"
    environment:
      TIMESCALEDB_URL: postgresql://user:pass@timescaledb:5432/analytics
      CLICKHOUSE_URL: clickhouse://clickhouse:9000

  # Notification Service
  notification-service:
    build: ./services/notifications
    environment:
      FIREBASE_CONFIG: /config/firebase.json
      KAFKA_BROKERS: kafka:9092

  # Databases
  postgres:
    image: postgres:14
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  timescaledb:
    image: timescale/timescaledb:latest-pg14
    volumes:
      - timescale_data:/var/lib/postgresql/data

  clickhouse:
    image: clickhouse/clickhouse-server:latest
    volumes:
      - clickhouse_data:/var/lib/clickhouse

  # Message Queue
  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper

  zookeeper:
    image: confluentinc/cp-zookeeper:latest

  # Search
  elasticsearch:
    image: elasticsearch:8.8.0
    volumes:
      - elastic_data:/usr/share/elasticsearch/data

  # ML Infrastructure
  tensorflow-serving:
    image: tensorflow/serving:latest
    volumes:
      - ./models:/models

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  postgres_data:
  redis_data:
  timescale_data:
  clickhouse_data:
  elastic_data:
  prometheus_data:
  grafana_data:
```

---

## 🚀 Prochaines Étapes d'Implémentation

### Phase 1: Fondations (4 semaines)
1. **Semaine 1:** Mise en place microservices + Event bus
2. **Semaine 2:** Migration données + Caching Redis
3. **Semaine 3:** API GraphQL + WebSockets
4. **Semaine 4:** Tests d'intégration + CI/CD

### Phase 2: Intelligence (6 semaines)
1. **Semaine 5-6:** Goal Recommendation Engine
2. **Semaine 7-8:** Behavior Prediction Model
3. **Semaine 9-10:** Image Recognition + NLP

### Phase 3: Gamification (4 semaines)
1. **Semaine 11-12:** Système de niveaux + XP
2. **Semaine 13-14:** Achievements + Défis communautaires

### Phase 4: UX Immersive (6 semaines)
1. **Semaine 15-16:** Animations 3D du sablier
2. **Semaine 17-18:** Mode AR
3. **Semaine 19-20:** Audio adaptatif + Effets visuels

### Phase 5: Analytics (4 semaines)
1. **Semaine 21-22:** Dashboard avancé
2. **Semaine 23-24:** Insights prédictifs

---

## 💰 Estimation des Coûts (Production à 100K users)

### Infrastructure
- **API Gateway (Kong):** $500/mois
- **Microservices (8 services, 2 instances each):** $800/mois
- **Databases:**
  - PostgreSQL (Supabase Pro): $250/mois
  - Redis (AWS ElastiCache): $150/mois
  - TimescaleDB: $200/mois
  - ClickHouse: $300/mois
- **Storage (S3):** $100/mois
- **CDN (Cloudflare):** $200/mois
- **Kafka (Confluent Cloud):** $400/mois

### ML/AI
- **OpenAI API (GPT-4):** $500/mois
- **TensorFlow Serving:** $300/mois
- **Image Recognition:** $200/mois

### Monitoring & Analytics
- **Datadog/New Relic:** $300/mois
- **Sentry:** $100/mois

**Total mensuel:** ~$4,300/mois

---

## 📈 Métriques de Succès

### KPIs Techniques
- **Uptime:** 99.9%
- **API Response time:** <200ms (p95)
- **ML Model Accuracy:** >85%
- **Cache Hit Rate:** >90%

### KPIs Business
- **DAU (Daily Active Users):** 10,000+
- **Retention (D30):** 60%+
- **Avg session duration:** 15+ minutes
- **Goal completion rate:** 70%+
- **Social interactions/user/week:** 5+

---

**Cette architecture transforme HOURGLASS en une application de classe mondiale, prête à scaler et à offrir une expérience utilisateur exceptionnelle.** 🚀✨
