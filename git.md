# 🧠 Guide Git — Revenir à une ancienne version d’un fichier

---

## 1️⃣ Voir l’historique des commits

Avant de revenir en arrière, il faut identifier le bon commit :

```bash
git log --oneline
```

### Exemple :

```
a1b2c3f Correction formulaire contact
d4e5f6a Mise à jour style CSS
7g8h9i0 Version initiale du formulaire
```

* Le **hash** (ex: `a1b2c3f`) identifie le commit
* Le message décrit les modifications

---

## 2️⃣ Récupérer un ancien fichier (sans toucher au reste)

Pour restaurer uniquement un fichier spécifique :

```bash
git checkout <commit_hash> -- chemin/vers/le/fichier
```

### Exemple :

```bash
git checkout 7g8h9i0 -- script.js
```

✅ Remplace `script.js` par sa version du commit choisi
❌ Ne modifie pas les autres fichiers

---

## 3️⃣ Vérifier les changements

Après récupération :

```bash
git status
```

Pour voir les différences :

```bash
git diff script.js
```

---

## 4️⃣ Valider la récupération

Si le résultat te convient :

```bash
git add script.js
git commit -m "Revenir à une ancienne version de script.js"
```

---

## 5️⃣ Revenir à un commit complet (⚠️ destructif)

Pour remettre **tout le projet** à un ancien état :

```bash
git reset --hard <commit_hash>
```

⚠️ Attention :

* Supprime toutes les modifications non commit
* À utiliser avec prudence

---

## 6️⃣ Tester un ancien commit (sans rien casser)

```bash
git checkout <commit_hash>
```

* Mode **detached HEAD**
* Permet de tester une version ancienne

### Revenir à ta branche :

```bash
git checkout main
```

---

## 🚀 Workflow recommandé (rapide)

```bash
# 1. Voir les commits
git log --oneline

# 2. Récupérer un fichier précis
git checkout <commit_hash> -- script.js

# 3. Vérifier
git diff script.js

# 4. Valider
git add script.js
git commit -m "Rollback script.js"
```

---

## 💡 Astuce pro

Utilise souvent :

```bash
git log --oneline --graph --decorate
```

👉 Pour visualiser clairement l’historique du projet

---

## 🎯 Conclusion

* Git permet de revenir en arrière sans copier-coller
* Tu peux restaurer un fichier précis ou tout le projet
* Toujours vérifier avant de commit

---

✅ Avec ça, tu n’auras plus jamais besoin de copier-coller depuis un ancien commit 😄
