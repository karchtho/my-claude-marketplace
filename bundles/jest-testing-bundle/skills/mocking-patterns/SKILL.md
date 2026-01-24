---
name: mocking-patterns
description: Jest mocking patterns, jest.fn(), jest.mock(), spies, module mocking, dependency injection, mock implementations. Activates when user mentions "mock", "jest.fn", "jest.mock", "spy", "stub", "fake", "dependency injection testing", or wants to isolate code for testing.
version: 1.0.0
---

# Jest Mocking Patterns

Master Jest mocking techniques to isolate code under test from external dependencies.

## Basic Mocking with jest.fn()

### Creating Mock Functions

```typescript
// Simple mock function
const mockFn = jest.fn();
mockFn('arg1', 'arg2');

expect(mockFn).toHaveBeenCalled();
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2');
expect(mockFn).toHaveBeenCalledTimes(1);

// Mock with return value
const mockWithReturn = jest.fn().mockReturnValue(42);
expect(mockWithReturn()).toBe(42);

// Mock with different return values
const mockSequence = jest.fn()
  .mockReturnValueOnce(1)
  .mockReturnValueOnce(2)
  .mockReturnValue(3);

expect(mockSequence()).toBe(1);
expect(mockSequence()).toBe(2);
expect(mockSequence()).toBe(3);
expect(mockSequence()).toBe(3); // Default after sequence

// Mock with implementation
const mockImpl = jest.fn((a: number, b: number) => a + b);
expect(mockImpl(2, 3)).toBe(5);
```

### Async Mock Functions

```typescript
// Mock resolved promise
const mockAsync = jest.fn().mockResolvedValue({ id: 1, name: 'Test' });
await expect(mockAsync()).resolves.toEqual({ id: 1, name: 'Test' });

// Mock rejected promise
const mockReject = jest.fn().mockRejectedValue(new Error('Failed'));
await expect(mockReject()).rejects.toThrow('Failed');

// Sequence of async results
const mockAsyncSequence = jest.fn()
  .mockResolvedValueOnce({ page: 1 })
  .mockResolvedValueOnce({ page: 2 })
  .mockRejectedValueOnce(new Error('No more pages'));
```

## Module Mocking with jest.mock()

### Mocking Entire Modules

```typescript
// Mock entire module
jest.mock('../services/email.service');

import { EmailService } from '../services/email.service';

// All methods are automatically mocked
const emailService = new EmailService();
expect(jest.isMockFunction(emailService.send)).toBe(true);

// Configure mock behavior
(emailService.send as jest.Mock).mockResolvedValue({ success: true });
```

### Mocking with Factory Function

```typescript
// Mock with custom implementation
jest.mock('../lib/database', () => ({
  query: jest.fn(),
  connect: jest.fn().mockResolvedValue(true),
  disconnect: jest.fn()
}));

import { query, connect, disconnect } from '../lib/database';

describe('Database operations', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should query database', async () => {
    (query as jest.Mock).mockResolvedValue([{ id: 1 }]);

    const result = await query('SELECT * FROM users');

    expect(result).toEqual([{ id: 1 }]);
    expect(query).toHaveBeenCalledWith('SELECT * FROM users');
  });
});
```

### Partial Module Mocking

```typescript
// Mock only specific exports
jest.mock('../utils/helpers', () => ({
  ...jest.requireActual('../utils/helpers'),
  fetchData: jest.fn() // Only mock fetchData
}));

import { formatDate, fetchData } from '../utils/helpers';

// formatDate is the real implementation
expect(formatDate(new Date('2024-01-01'))).toBe('2024-01-01');

// fetchData is mocked
(fetchData as jest.Mock).mockResolvedValue({ data: 'mocked' });
```

### Mocking Node Modules

```typescript
// Mock axios
jest.mock('axios');
import axios from 'axios';

const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('API Client', () => {
  it('should fetch data', async () => {
    mockedAxios.get.mockResolvedValue({
      data: { users: [{ id: 1 }] }
    });

    const response = await axios.get('/api/users');

    expect(response.data.users).toHaveLength(1);
  });
});

// Mock nodemailer
jest.mock('nodemailer', () => ({
  createTransport: jest.fn(() => ({
    sendMail: jest.fn().mockResolvedValue({ messageId: 'test-id' })
  }))
}));
```

## Spying on Functions

### Spying on Object Methods

```typescript
const calculator = {
  add: (a: number, b: number) => a + b,
  multiply: (a: number, b: number) => a * b
};

describe('Calculator spy', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('should spy on add method', () => {
    const addSpy = jest.spyOn(calculator, 'add');

    const result = calculator.add(2, 3);

    expect(addSpy).toHaveBeenCalledWith(2, 3);
    expect(result).toBe(5); // Real implementation called
  });

  it('should mock return value while spying', () => {
    const addSpy = jest.spyOn(calculator, 'add').mockReturnValue(100);

    const result = calculator.add(2, 3);

    expect(addSpy).toHaveBeenCalled();
    expect(result).toBe(100); // Mocked value
  });
});
```

### Spying on Module Functions

```typescript
import * as mathUtils from '../utils/math';

describe('Math utils spy', () => {
  it('should spy on exported function', () => {
    const spy = jest.spyOn(mathUtils, 'calculateTax');

    mathUtils.calculateTax(100, 0.1);

    expect(spy).toHaveBeenCalledWith(100, 0.1);
  });
});
```

## Dependency Injection Pattern

### Constructor Injection

```typescript
// services/user.service.ts
interface UserRepository {
  findById(id: string): Promise<User | null>;
  save(user: User): Promise<User>;
}

interface EmailService {
  send(to: string, subject: string, body: string): Promise<void>;
}

export class UserService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}

  async registerUser(data: CreateUserDTO): Promise<User> {
    const user = await this.userRepository.save({
      id: generateId(),
      ...data,
      createdAt: new Date()
    });

    await this.emailService.send(
      user.email,
      'Welcome!',
      `Hello ${user.name}, welcome to our platform!`
    );

    return user;
  }
}

// services/user.service.test.ts
describe('UserService', () => {
  let service: UserService;
  let mockUserRepository: jest.Mocked<UserRepository>;
  let mockEmailService: jest.Mocked<EmailService>;

  beforeEach(() => {
    mockUserRepository = {
      findById: jest.fn(),
      save: jest.fn()
    };
    mockEmailService = {
      send: jest.fn()
    };
    service = new UserService(mockUserRepository, mockEmailService);
  });

  it('should register user and send welcome email', async () => {
    const userData = { name: 'John', email: 'john@example.com' };
    const savedUser = { id: '123', ...userData, createdAt: new Date() };

    mockUserRepository.save.mockResolvedValue(savedUser);
    mockEmailService.send.mockResolvedValue();

    const result = await service.registerUser(userData);

    expect(result).toEqual(savedUser);
    expect(mockUserRepository.save).toHaveBeenCalledWith(
      expect.objectContaining({ name: 'John', email: 'john@example.com' })
    );
    expect(mockEmailService.send).toHaveBeenCalledWith(
      'john@example.com',
      'Welcome!',
      expect.stringContaining('John')
    );
  });

  it('should not send email if save fails', async () => {
    mockUserRepository.save.mockRejectedValue(new Error('DB error'));

    await expect(
      service.registerUser({ name: 'John', email: 'john@example.com' })
    ).rejects.toThrow('DB error');

    expect(mockEmailService.send).not.toHaveBeenCalled();
  });
});
```

## Mocking External APIs

```typescript
// services/weather.service.ts
import axios from 'axios';

export class WeatherService {
  private apiKey: string;
  private baseUrl = 'https://api.weather.com';

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  async getWeather(city: string): Promise<WeatherData> {
    const response = await axios.get(`${this.baseUrl}/current`, {
      params: { city, apiKey: this.apiKey }
    });
    return response.data;
  }
}

// services/weather.service.test.ts
jest.mock('axios');
import axios from 'axios';
import { WeatherService } from './weather.service';

const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('WeatherService', () => {
  let service: WeatherService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new WeatherService('test-api-key');
  });

  it('should fetch weather data', async () => {
    const mockWeather = {
      city: 'London',
      temperature: 20,
      conditions: 'Sunny'
    };
    mockedAxios.get.mockResolvedValue({ data: mockWeather });

    const result = await service.getWeather('London');

    expect(result).toEqual(mockWeather);
    expect(mockedAxios.get).toHaveBeenCalledWith(
      'https://api.weather.com/current',
      { params: { city: 'London', apiKey: 'test-api-key' } }
    );
  });

  it('should handle API errors', async () => {
    mockedAxios.get.mockRejectedValue(new Error('Network error'));

    await expect(service.getWeather('London')).rejects.toThrow('Network error');
  });

  it('should handle rate limiting', async () => {
    mockedAxios.get.mockRejectedValue({
      response: { status: 429, data: { message: 'Rate limit exceeded' } }
    });

    await expect(service.getWeather('London')).rejects.toMatchObject({
      response: { status: 429 }
    });
  });
});
```

## Timer Mocking

```typescript
describe('Timer functions', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should debounce function calls', () => {
    const callback = jest.fn();
    const debounced = debounce(callback, 1000);

    debounced();
    debounced();
    debounced();

    expect(callback).not.toHaveBeenCalled();

    jest.advanceTimersByTime(1000);

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('should retry with exponential backoff', async () => {
    const mockFetch = jest.fn()
      .mockRejectedValueOnce(new Error('Fail 1'))
      .mockRejectedValueOnce(new Error('Fail 2'))
      .mockResolvedValue({ data: 'success' });

    const promise = retryWithBackoff(mockFetch, 3);

    // First attempt fails immediately
    await jest.advanceTimersByTimeAsync(0);
    expect(mockFetch).toHaveBeenCalledTimes(1);

    // Wait for first retry (1000ms)
    await jest.advanceTimersByTimeAsync(1000);
    expect(mockFetch).toHaveBeenCalledTimes(2);

    // Wait for second retry (2000ms)
    await jest.advanceTimersByTimeAsync(2000);
    expect(mockFetch).toHaveBeenCalledTimes(3);

    const result = await promise;
    expect(result).toEqual({ data: 'success' });
  });
});
```

## Mocking Date and Time

```typescript
describe('Date-dependent functions', () => {
  beforeEach(() => {
    jest.useFakeTimers();
    jest.setSystemTime(new Date('2024-01-15T10:00:00Z'));
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('should format current date', () => {
    const result = formatCurrentDate();
    expect(result).toBe('January 15, 2024');
  });

  it('should check if subscription is expired', () => {
    const expiredSub = { expiresAt: new Date('2024-01-10') };
    const activeSub = { expiresAt: new Date('2024-01-20') };

    expect(isExpired(expiredSub)).toBe(true);
    expect(isExpired(activeSub)).toBe(false);
  });
});
```

## Mock Assertions

```typescript
describe('Mock assertions', () => {
  const mockFn = jest.fn();

  beforeEach(() => {
    mockFn.mockClear();
  });

  it('should verify call count', () => {
    mockFn();
    mockFn();
    mockFn();

    expect(mockFn).toHaveBeenCalledTimes(3);
  });

  it('should verify call arguments', () => {
    mockFn('first', 1);
    mockFn('second', 2);

    expect(mockFn).toHaveBeenNthCalledWith(1, 'first', 1);
    expect(mockFn).toHaveBeenNthCalledWith(2, 'second', 2);
    expect(mockFn).toHaveBeenLastCalledWith('second', 2);
  });

  it('should verify partial arguments', () => {
    mockFn({ id: 1, name: 'Test', extra: 'data' });

    expect(mockFn).toHaveBeenCalledWith(
      expect.objectContaining({ id: 1, name: 'Test' })
    );
  });

  it('should verify array arguments', () => {
    mockFn([1, 2, 3]);

    expect(mockFn).toHaveBeenCalledWith(
      expect.arrayContaining([1, 2])
    );
  });
});
```

## Clearing and Resetting Mocks

```typescript
describe('Mock lifecycle', () => {
  const mockFn = jest.fn().mockReturnValue('default');

  // Clear call history but keep implementation
  afterEach(() => {
    mockFn.mockClear();
  });

  // OR reset to initial state (clears history AND implementation)
  afterEach(() => {
    mockFn.mockReset();
  });

  // OR restore original implementation (for spies)
  afterEach(() => {
    jest.restoreAllMocks();
  });

  // Clear all mocks globally
  afterEach(() => {
    jest.clearAllMocks();
  });
});
```

## Best Practices

1. **Clear mocks between tests** - Use `jest.clearAllMocks()` in `beforeEach` or `afterEach`
2. **Use dependency injection** - Makes code easier to test with mock dependencies
3. **Mock at boundaries** - Mock external APIs, databases, file systems
4. **Don't mock what you own** - Prefer testing real implementations when possible
5. **Keep mocks simple** - Only mock what's necessary for the test
6. **Verify mock calls** - Assert that mocks were called with expected arguments
7. **Use typed mocks** - Use `jest.Mocked<T>` for type safety
8. **Restore spies** - Always restore spies in `afterEach` to prevent test pollution
