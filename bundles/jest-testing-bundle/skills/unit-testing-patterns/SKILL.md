---
name: unit-testing-patterns
description: Unit testing patterns, TDD workflow, test factories, fixtures, pure function testing, class testing. Activates when user mentions "unit test", "TDD", "test-driven", "factory pattern", "test fixtures", "pure function testing", "class testing", or wants to write isolated unit tests.
version: 1.0.0
---

# Unit Testing Patterns

Comprehensive patterns for writing effective, maintainable unit tests following TDD principles.

## Test-Driven Development (TDD)

### The TDD Cycle

1. **Red** - Write a failing test first
2. **Green** - Write minimal code to pass the test
3. **Refactor** - Improve code while keeping tests green

```typescript
// Step 1: RED - Write failing test
describe('Calculator', () => {
  it('should add two numbers', () => {
    const calc = new Calculator();
    expect(calc.add(2, 3)).toBe(5);
  });
});

// Step 2: GREEN - Minimal implementation
class Calculator {
  add(a: number, b: number): number {
    return a + b;
  }
}

// Step 3: REFACTOR - Improve if needed
// (In this case, implementation is already clean)
```

### TDD Rules

- Never write production code without a failing test
- Write only enough test to fail
- Write only enough code to pass
- Refactor only when tests are green

## Factory Pattern for Test Data

### Basic Factory

```typescript
// factories/user.factory.ts
import { faker } from '@faker-js/faker';

interface User {
  id: string;
  name: string;
  email: string;
  role: 'user' | 'admin';
  createdAt: Date;
}

export function createUserFixture(overrides?: Partial<User>): User {
  return {
    id: faker.string.uuid(),
    name: faker.person.fullName(),
    email: faker.internet.email(),
    role: 'user',
    createdAt: new Date(),
    ...overrides
  };
}

// Usage in tests
it('should allow admin to delete users', () => {
  const admin = createUserFixture({ role: 'admin' });
  const user = createUserFixture();

  const result = userService.delete(user.id, admin);

  expect(result.success).toBe(true);
});
```

### Props Factory for Components

```typescript
// factories/component-props.factory.ts
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled: boolean;
  variant: 'primary' | 'secondary';
  loading: boolean;
}

export function createButtonProps(overrides?: Partial<ButtonProps>): ButtonProps {
  return {
    label: 'Click me',
    onClick: jest.fn(),
    disabled: false,
    variant: 'primary',
    loading: false,
    ...overrides
  };
}

// Usage
it('should not trigger onClick when disabled', () => {
  const props = createButtonProps({ disabled: true });

  render(<Button {...props} />);
  fireEvent.click(screen.getByRole('button'));

  expect(props.onClick).not.toHaveBeenCalled();
});
```

### Complex Data Factory

```typescript
// factories/order.factory.ts
interface OrderItem {
  productId: string;
  name: string;
  price: number;
  quantity: number;
}

interface Order {
  id: string;
  userId: string;
  items: OrderItem[];
  status: 'pending' | 'paid' | 'shipped' | 'delivered';
  total: number;
  createdAt: Date;
}

export function createOrderItemFixture(overrides?: Partial<OrderItem>): OrderItem {
  const price = overrides?.price ?? faker.number.float({ min: 10, max: 100, fractionDigits: 2 });
  const quantity = overrides?.quantity ?? faker.number.int({ min: 1, max: 5 });

  return {
    productId: faker.string.uuid(),
    name: faker.commerce.productName(),
    price,
    quantity,
    ...overrides
  };
}

export function createOrderFixture(overrides?: Partial<Order>): Order {
  const items = overrides?.items ?? [createOrderItemFixture(), createOrderItemFixture()];
  const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  return {
    id: faker.string.uuid(),
    userId: faker.string.uuid(),
    items,
    status: 'pending',
    total,
    createdAt: new Date(),
    ...overrides
  };
}
```

## Testing Pure Functions

```typescript
// utils/math.ts
export function calculateDiscount(price: number, discountPercent: number): number {
  if (price < 0) throw new Error('Price cannot be negative');
  if (discountPercent < 0 || discountPercent > 100) {
    throw new Error('Discount must be between 0 and 100');
  }
  return price * (1 - discountPercent / 100);
}

// utils/math.test.ts
describe('calculateDiscount', () => {
  describe('valid inputs', () => {
    it('should apply 10% discount correctly', () => {
      expect(calculateDiscount(100, 10)).toBe(90);
    });

    it('should handle 0% discount', () => {
      expect(calculateDiscount(100, 0)).toBe(100);
    });

    it('should handle 100% discount', () => {
      expect(calculateDiscount(100, 100)).toBe(0);
    });

    it('should handle decimal prices', () => {
      expect(calculateDiscount(99.99, 10)).toBeCloseTo(89.991, 2);
    });
  });

  describe('edge cases', () => {
    it('should handle zero price', () => {
      expect(calculateDiscount(0, 50)).toBe(0);
    });
  });

  describe('error handling', () => {
    it('should throw for negative price', () => {
      expect(() => calculateDiscount(-10, 10)).toThrow('Price cannot be negative');
    });

    it('should throw for discount below 0', () => {
      expect(() => calculateDiscount(100, -10)).toThrow('Discount must be between 0 and 100');
    });

    it('should throw for discount above 100', () => {
      expect(() => calculateDiscount(100, 150)).toThrow('Discount must be between 0 and 100');
    });
  });
});
```

## Testing Classes

```typescript
// services/cart.service.ts
interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

export class CartService {
  private items: Map<string, CartItem> = new Map();

  addItem(item: Omit<CartItem, 'quantity'>, quantity = 1): void {
    const existing = this.items.get(item.id);
    if (existing) {
      existing.quantity += quantity;
    } else {
      this.items.set(item.id, { ...item, quantity });
    }
  }

  removeItem(id: string): boolean {
    return this.items.delete(id);
  }

  getTotal(): number {
    let total = 0;
    this.items.forEach(item => {
      total += item.price * item.quantity;
    });
    return total;
  }

  getItemCount(): number {
    let count = 0;
    this.items.forEach(item => {
      count += item.quantity;
    });
    return count;
  }

  clear(): void {
    this.items.clear();
  }
}

// services/cart.service.test.ts
describe('CartService', () => {
  let cart: CartService;

  beforeEach(() => {
    cart = new CartService();
  });

  describe('addItem', () => {
    it('should add new item to cart', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 });

      expect(cart.getItemCount()).toBe(1);
      expect(cart.getTotal()).toBe(10);
    });

    it('should increase quantity for existing item', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 });
      cart.addItem({ id: '1', name: 'Widget', price: 10 }, 2);

      expect(cart.getItemCount()).toBe(3);
      expect(cart.getTotal()).toBe(30);
    });

    it('should handle multiple different items', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 });
      cart.addItem({ id: '2', name: 'Gadget', price: 20 });

      expect(cart.getItemCount()).toBe(2);
      expect(cart.getTotal()).toBe(30);
    });
  });

  describe('removeItem', () => {
    it('should remove existing item', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 });

      const result = cart.removeItem('1');

      expect(result).toBe(true);
      expect(cart.getItemCount()).toBe(0);
    });

    it('should return false for non-existent item', () => {
      const result = cart.removeItem('non-existent');

      expect(result).toBe(false);
    });
  });

  describe('getTotal', () => {
    it('should return 0 for empty cart', () => {
      expect(cart.getTotal()).toBe(0);
    });

    it('should calculate total correctly with quantities', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 }, 3);
      cart.addItem({ id: '2', name: 'Gadget', price: 25 }, 2);

      expect(cart.getTotal()).toBe(80); // 30 + 50
    });
  });

  describe('clear', () => {
    it('should remove all items', () => {
      cart.addItem({ id: '1', name: 'Widget', price: 10 });
      cart.addItem({ id: '2', name: 'Gadget', price: 20 });

      cart.clear();

      expect(cart.getItemCount()).toBe(0);
      expect(cart.getTotal()).toBe(0);
    });
  });
});
```

## Testing Async Functions

```typescript
// services/user.service.ts
interface User {
  id: string;
  name: string;
  email: string;
}

interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<User>;
}

export class UserService {
  constructor(private repository: UserRepository) {}

  async getUser(id: string): Promise<User> {
    const user = await this.repository.findById(id);
    if (!user) {
      throw new Error(`User ${id} not found`);
    }
    return user;
  }

  async updateEmail(id: string, newEmail: string): Promise<User> {
    const user = await this.getUser(id);
    user.email = newEmail;
    return this.repository.save(user);
  }
}

// services/user.service.test.ts
describe('UserService', () => {
  let service: UserService;
  let mockRepository: jest.Mocked<UserRepository>;

  beforeEach(() => {
    mockRepository = {
      findById: jest.fn(),
      save: jest.fn()
    };
    service = new UserService(mockRepository);
  });

  describe('getUser', () => {
    it('should return user when found', async () => {
      const expectedUser = { id: '1', name: 'John', email: 'john@example.com' };
      mockRepository.findById.mockResolvedValue(expectedUser);

      const user = await service.getUser('1');

      expect(user).toEqual(expectedUser);
      expect(mockRepository.findById).toHaveBeenCalledWith('1');
    });

    it('should throw when user not found', async () => {
      mockRepository.findById.mockResolvedValue(null);

      await expect(service.getUser('999')).rejects.toThrow('User 999 not found');
    });
  });

  describe('updateEmail', () => {
    it('should update user email', async () => {
      const existingUser = { id: '1', name: 'John', email: 'old@example.com' };
      const updatedUser = { ...existingUser, email: 'new@example.com' };

      mockRepository.findById.mockResolvedValue(existingUser);
      mockRepository.save.mockResolvedValue(updatedUser);

      const result = await service.updateEmail('1', 'new@example.com');

      expect(result.email).toBe('new@example.com');
      expect(mockRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ email: 'new@example.com' })
      );
    });
  });
});
```

## Parameterized Tests

```typescript
describe('isValidEmail', () => {
  const validEmails = [
    'test@example.com',
    'user.name@domain.org',
    'user+tag@example.co.uk'
  ];

  const invalidEmails = [
    'invalid',
    '@nodomain.com',
    'no@domain',
    'spaces in@email.com',
    ''
  ];

  it.each(validEmails)('should accept valid email: %s', (email) => {
    expect(isValidEmail(email)).toBe(true);
  });

  it.each(invalidEmails)('should reject invalid email: %s', (email) => {
    expect(isValidEmail(email)).toBe(false);
  });
});

// Table format for complex cases
describe('calculateShipping', () => {
  it.each([
    { weight: 1, distance: 10, expected: 5.00 },
    { weight: 5, distance: 10, expected: 10.00 },
    { weight: 1, distance: 100, expected: 15.00 },
    { weight: 10, distance: 500, expected: 75.00 }
  ])('should calculate $expected for $weight kg over $distance km',
    ({ weight, distance, expected }) => {
      expect(calculateShipping(weight, distance)).toBe(expected);
    }
  );
});
```

## Best Practices

1. **Test behavior, not implementation** - Focus on what the code does, not how it does it
2. **One logical assertion per test** - Keep tests focused and easy to debug
3. **Use descriptive test names** - Names should explain scenario and expected outcome
4. **Use factories for test data** - Keep test data consistent and maintainable
5. **Follow AAA pattern** - Arrange, Act, Assert for clear structure
6. **Mock external dependencies** - Keep unit tests fast and isolated
7. **Test edge cases** - Include boundary conditions and error scenarios
8. **Keep tests independent** - No test should depend on another test's state
