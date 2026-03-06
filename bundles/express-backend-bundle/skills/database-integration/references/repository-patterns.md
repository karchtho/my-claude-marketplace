# Repository Patterns with Prisma

The repository layer owns one thing: Prisma queries. No business logic, no error throwing (except Prisma's own errors), no data transformation.

## The Rule

| Repository does | Service does |
|---|---|
| `findUnique`, `findMany`, `create`, `update`, `delete` | Existence checks (`if (!recipe) throw new NotFoundError()`) |
| `include` / `select` for relations | Data transformation (snake_case DB -> camelCase API) |
| Build `where` clauses | Cross-entity business rules |
| Return raw Prisma objects | Shape the API response object |

## Function Naming Convention

```javascript
find*   // queries — findRecipeById, findAllRecipes, findRecipesByUserId
create* // inserts — createRecipe, createRecipeReport
update* // updates — updateRecipe, updateRecipeStatus
delete* // deletes — deleteRecipe
```

## Simple Query

```javascript
// repositories/recipes.repository.js
import { prisma } from '../config/database.js';

export const findRecipeById = async (recipeId) => {
  return prisma.recipes.findUnique({
    where: { recipe_id: Number(recipeId) },
    include: {
      users: {
        select: { user_id: true, pseudonyme: true, anonymized: true },
      },
      status: true,
      steps: true,
      recipe_tags: { include: { tags: true } },
    },
  });
  // Returns null if not found — the SERVICE checks this and throws NotFoundError
};
```

## Nested Create (Many-to-Many)

```javascript
export const createRecipe = async (data) => {
  return prisma.recipes.create({
    data: {
      title: data.title,
      preparation_time: data.preparationTime,  // snake_case for DB
      users: { connect: { user_id: data.userId } },
      status: { connect: { status_id: data.statusId } },
      // Many-to-many: create junction rows via nested relation
      recipe_tags: {
        create: data.tagIds.map(tagId => ({ tag_id: tagId })),
      },
      recipe_ingredients: {
        create: data.ingredients.map(i => ({
          quantity: i.quantity,
          ingredients: { connect: { ingredient_id: i.ingredientId } },
          ingredient_units: {
            connect: {
              ingredient_id_unit_id: {
                ingredient_id: i.ingredientId,
                unit_id: i.unitId,
              },
            },
          },
        })),
      },
    },
  });
};
```

## Simple CRUD (for simpler schemas)

```javascript
export const findAllAlbumsWithArtists = () =>
  prisma.album.findMany({ include: { artist: true } });

export const findAlbumById = (albumId) =>
  prisma.album.findUnique({ where: { id: albumId }, include: { artist: true } });

export const createAlbum = (data) =>
  prisma.album.create({ data });

export const updateAlbum = (albumId, data) =>
  prisma.album.update({ where: { id: albumId }, data });

export const deleteAlbum = (albumId) =>
  prisma.album.delete({ where: { id: albumId } });
```

## The Service Layer Owns Existence Checks

```javascript
// services/recipes.service.js — the service calls repo then checks result
import { findRecipeById } from '../repositories/recipes.repository.js';
import { NotFoundError } from '../utils/errors.js';

export const fetchRecipeById = async (recipeId) => {
  const recipe = await findRecipeById(recipeId);       // repo returns null or object
  if (!recipe) throw new NotFoundError("Recipe not found");  // service throws
  return {
    id: recipe.recipe_id,         // transform: snake_case -> camelCase
    title: recipe.title,
    prepTime: recipe.preparation_time,
    author: {
      id: recipe.users.user_id,
      name: recipe.users.pseudonyme,
    },
  };
};
```

## Prisma Client — One Instance

Create the client once and import it everywhere:

```javascript
// config/database.js
import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient();
```

Never call `new PrismaClient()` in a repository file — that creates a new connection pool per import.
