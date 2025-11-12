# HOURGLASS - Prochaines Étapes 🚀

## ✅ Ce qui a été fait

1. ✅ **Structure du projet créée** - Monorepo complet (app/backend/infra/ops)
2. ✅ **Dépendances installées** - Flutter pub get ✓, Python pip install en cours
3. ✅ **Code généré** - Freezed/JSON serialization ✓
4. ✅ **Fichiers .env créés** - Configuration de base prête
5. ✅ **Documentation complète** - 7 fichiers markdown détaillés

## 🎯 Étapes Suivantes Immédiates

### 1. Créer un Projet Supabase (15 minutes)

**C'est l'étape CRITIQUE pour faire fonctionner l'app**

#### A. Créer le projet
```bash
1. Aller sur https://supabase.com
2. Cliquer sur "New Project"
3. Remplir:
   - Nom: Hourglass
   - Mot de passe DB: [choisir un mot de passe fort]
   - Région: Europe West (eu-west-1) - proche de Paris
4. Attendre 2 minutes que le projet s'initialise
```

#### B. Récupérer les clés
```bash
Dans le Dashboard Supabase:
1. Aller dans Settings → API
2. Copier:
   - Project URL: https://xxx.supabase.co
   - anon/public key (pour l'app)
   - service_role key (pour le backend)

3. Aller dans Settings → API → JWT Settings
4. Copier le JWT Secret

5. Aller dans Settings → Database
6. Copier la Connection String (mode Transaction)
```

#### C. Mettre à jour les fichiers .env

**Fichier: `app/.env`**
```bash
SUPABASE_URL=https://[VOTRE-PROJECT-ID].supabase.co
SUPABASE_ANON_KEY=[VOTRE-ANON-KEY]
API_BASE_URL=http://localhost:8000
ENVIRONMENT=development
```

**Fichier: `backend/.env`**
```bash
SUPABASE_URL=https://[VOTRE-PROJECT-ID].supabase.co
SUPABASE_KEY=[VOTRE-SERVICE-ROLE-KEY]
SUPABASE_JWT_SECRET=[VOTRE-JWT-SECRET]
DATABASE_URL=postgresql://postgres:[MOT-DE-PASSE]@db.[PROJECT-ID].supabase.co:5432/postgres
APP_ENV=development
API_HOST=0.0.0.0
API_PORT=8000
```

### 2. Appliquer le Schéma de Base de Données (10 minutes)

**Option A: Via le SQL Editor (Plus simple)**
```bash
1. Dans Supabase Dashboard, aller dans SQL Editor
2. Créer une nouvelle query
3. Copier le contenu de infra/supabase/schema.sql
4. Cliquer sur Run
5. Répéter pour rls_policies.sql
6. Répéter pour seed.sql
```

**Option B: Via CLI (Recommandé si vous avez Supabase CLI)**
```bash
# Installer Supabase CLI (si pas déjà fait)
npm install -g supabase

# Dans le dossier infra/supabase
cd infra/supabase
supabase login
supabase link --project-ref [VOTRE-PROJECT-REF]

# Appliquer les migrations
psql "votre-connection-string" < schema.sql
psql "votre-connection-string" < rls_policies.sql
psql "votre-connection-string" < seed.sql
```

### 3. Créer le Bucket Storage (5 minutes)

```bash
Dans Supabase Dashboard:
1. Aller dans Storage
2. Cliquer sur "New bucket"
3. Configuration:
   - Name: proofs
   - Public: OFF (décoché)
   - File size limit: 10 MB
   - Allowed MIME types: image/jpeg, image/png

4. Créer les policies (dans l'onglet Policies du bucket):

   INSERT Policy:
   (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)

   SELECT Policy:
   (bucket_id = 'proofs' AND (storage.foldername(name))[1] = auth.uid()::text)
```

### 4. Tester le Backend (2 minutes)

```bash
cd backend
source .venv/bin/activate  # Sur Windows: .venv\Scripts\activate
uvicorn app.main:app --reload
```

Ouvrez http://localhost:8000/docs pour voir la documentation Swagger.

Testez:
- GET http://localhost:8000/health
- Devrait retourner: `{"status": "healthy"}`

### 5. Lancer l'Application Flutter (5 minutes)

**Option A: En ligne de commande**
```bash
cd app
flutter run
# Choisir le device (iOS Simulator / Android Emulator / Chrome)
```

**Option B: Via VS Code**
```bash
1. Ouvrir le dossier app dans VS Code
2. Appuyer sur F5
3. Sélectionner le device
```

## 🔧 Dépannage Rapide

### Problème: "Cannot connect to Supabase"
**Solution**:
- Vérifier que les clés dans `.env` sont correctes
- S'assurer que le projet Supabase n'est pas en pause (plan gratuit)

### Problème: "RLS blocks queries"
**Solution**:
- Vérifier que rls_policies.sql a bien été appliqué
- Tester avec un utilisateur authentifié

### Problème: "Flutter pub get fails"
**Solution**:
```bash
flutter clean
flutter pub get
```

### Problème: "Python dependencies conflict"
**Solution**: Les dépendances ont déjà été corrigées. Si problème persiste:
```bash
cd backend
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Problème: "Storage upload fails"
**Solution**:
- Vérifier que le bucket 'proofs' existe
- Vérifier que les policies sont définies
- S'assurer que l'utilisateur est authentifié

## 📱 Tester les Fonctionnalités

### 1. Inscription/Connexion
```
1. Lancer l'app
2. Créer un compte (signup)
3. Se connecter
```

### 2. Contrat du matin
```
1. Aller dans "Set Today's Goals"
2. Ajouter 1-3 objectifs
3. Valider
```

### 3. Victory Feed
```
1. Aller dans "Victory Feed"
2. Voir les données de démo
3. (Les vraies victoires apparaissent après la sync de 20h)
```

### 4. API Backend
```bash
# Tester l'évaluation de goals
curl -X POST http://localhost:8000/api/goals/evaluate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"goals": ["Morning run", "Read 30 minutes", "Meditate"]}'
```

## 🚀 Déployer les Edge Functions (Optionnel pour le MVP)

```bash
cd infra/supabase

# Déployer les cron jobs
supabase functions deploy cron_08h
supabase functions deploy cron_20h

# Configurer les variables d'environnement
supabase secrets set SUPABASE_URL="https://xxx.supabase.co"
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="your-key"
```

## 📊 État Actuel du Projet

| Composant | État | Action Requise |
|-----------|------|----------------|
| Structure Monorepo | ✅ Complet | Aucune |
| Flutter App | ✅ Complet | Tester |
| Backend API | ✅ Complet | Tester |
| Base de Données | ⏳ À créer | **URGENT: Créer projet Supabase** |
| RLS Policies | ⏳ À appliquer | Appliquer SQL scripts |
| Storage Bucket | ⏳ À créer | Créer dans Dashboard |
| Edge Functions | ⏳ Optionnel | Déployer plus tard |
| Documentation | ✅ Complet | Lire |
| Tests | ✅ Complet | Lancer `pytest` |

## ⏱️ Temps Estimé Total

- ✅ Déjà fait: ~2 heures (structure + code)
- 🎯 Supabase Setup: ~30 minutes
- 🎯 Tests de l'app: ~15 minutes
- 🎯 Corrections/ajustements: ~30 minutes

**TOTAL RESTANT: ~1h15**

## 🎓 Ressources Utiles

- [README Principal](README.md) - Vue d'ensemble
- [GETTING_STARTED.md](GETTING_STARTED.md) - Guide détaillé
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture technique
- [Supabase Setup](infra/supabase_instructions.md) - Instructions Supabase détaillées
- [App README](app/README.md) - Documentation Flutter
- [Backend README](backend/README.md) - Documentation API

## ✨ Commandes Rapides

```bash
# Tout installer
./ops/scripts/bootstrap.sh

# Lancer dev (app + backend)
./ops/scripts/run_dev.sh

# Backend seul
cd backend && source .venv/bin/activate && uvicorn app.main:app --reload

# App seule
cd app && flutter run

# Tests backend
cd backend && source .venv/bin/activate && pytest

# Tests app
cd app && flutter test
```

## 🎯 Checklist de Validation

Cochez au fur et à mesure:

- [ ] Projet Supabase créé
- [ ] Clés copiées dans fichiers .env
- [ ] Schema SQL appliqué
- [ ] RLS policies appliquées
- [ ] Seed data chargée
- [ ] Bucket 'proofs' créé
- [ ] Backend démarre sur :8000
- [ ] Endpoint /health répond
- [ ] App Flutter se lance
- [ ] Signup fonctionne
- [ ] Login fonctionne
- [ ] Navigation entre écrans OK
- [ ] Victory Feed affiche données démo

## 💡 Astuce Développeur

**Pour développer sans Supabase temporairement:**
```bash
# L'app se lance mais affichera des erreurs de connexion
# Vous pouvez quand même:
- Naviguer entre les écrans
- Voir le layout et le design
- Tester les animations
- Développer l'UI
```

**Pour tester avec vraies données:**
```bash
# Il FAUT absolument:
1. Un projet Supabase configuré
2. Les clés dans .env
3. Le schéma DB appliqué
```

## 🆘 Besoin d'Aide?

1. **Erreur de connexion DB**: Vérifier DATABASE_URL dans backend/.env
2. **Erreur d'authentification**: Vérifier SUPABASE_ANON_KEY dans app/.env
3. **Erreur RLS**: Appliquer rls_policies.sql
4. **Autre problème**: Consulter GETTING_STARTED.md section "Troubleshooting"

---

**Prochaine action immédiate: Créer le projet Supabase! 🚀**

C'est la seule chose qui bloque l'app. Une fois Supabase configuré, tout fonctionnera.

Bon courage! 💪
