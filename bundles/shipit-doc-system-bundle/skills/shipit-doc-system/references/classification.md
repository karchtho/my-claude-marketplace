# Classification — quel type de document ?

Avant de rédiger, déterminer le type. La question décisive : **est-ce que je décris une consigne réutilisable, ou est-ce que j'enregistre la preuve d'une exécution ?**

## Arbre de décision

```
Le document décrit-il une POLITIQUE (règles, responsabilités, "pourquoi") ?
 ├─ OUI → SOP
 └─ NON
     Le document décrit-il les ÉTAPES d'une tâche ("comment faire") ?
      ├─ OUI → WI
      └─ NON
          Le document est-il un CATALOGUE / une donnée de référence ?
           ├─ OUI → REF
           └─ NON  (le document CAPTURE une preuve d'exécution)
               L'objet est-il une INSTALLATION ponctuelle ?
                ├─ OUI → IQ
                └─ NON (tâche récurrente OU revue de conformité) → OQ
```

## Le test décisif : instruction vs preuve

| Indice                                             | Type |
|----------------------------------------------------|------|
| Réutilisable tel quel à chaque fois                | SOP / WI / REF (document maître) |
| Contient des champs « Résultat constaté », des cases à cocher de conformité, un bloc de **signatures** | IQ / OQ (enregistrement) |
| Décrit *pourquoi* et *quelles règles*              | SOP |
| Décrit *comment*, pas à pas                        | WI |
| Vérifie qu'une **installation** est conforme       | IQ |
| Vérifie une **opération récurrente** ou la **conformité d'une politique** | OQ |

## Pièges fréquents (déjà rencontrés)

1. **IQ noyée dans une WI.** Une WI qui se termine par un tableau de critères + signatures mélange instruction et preuve. → Extraire la section dans une IQ/OQ autonome ; la WI n'y fait que référence.
2. **« IQ » pour une tâche récurrente.** Ajouter un peer VPN ou restaurer une sauvegarde n'est pas une *installation*. → C'est une **OQ**, pas une IQ.
3. **Tableau de qualification dans une SOP.** Une SOP est une politique ; elle ne porte pas de preuve d'exécution. La vérification de conformité va dans une **OQ** liée.
4. **Pas de traçabilité de version.** Une instance d'IQ/OQ doit indiquer **quelle version** du document maître a été suivie. Sans ce champ, l'enregistrement n'est pas auditable.
5. **Instance confondue avec modèle.** Le fichier `IQ-INFRA-XXX_*.md` est un modèle vierge versionné. Une exécution réelle est une **copie** nommée `..._<AAAA-MM-JJ>_<cible>.md`, figée une fois signée.

## Lien qualification ↔ source

Le lien n'est pas porté par le numéro mais par le champ **`Qualifie`** dans l'en-tête de l'IQ/OQ. Par commodité, une IQ d'installation reprend le numéro de sa WI (`IQ-INFRA-001` ↔ `WI-INFRA-001`), mais ce n'est qu'une aide de lecture.
