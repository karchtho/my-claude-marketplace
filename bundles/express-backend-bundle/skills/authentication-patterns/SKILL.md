---
name: authentication-patterns
description: JWT authentication, OAuth 2.0, session management, password hashing, refresh tokens, multi-factor authentication, API keys. Use when implementing user authentication, token management, authorization, password reset flows, or securing APIs.
---

# Authentication & Authorization Patterns

Master JWT, OAuth, sessions, password management, and API security.

## When to Use This Skill

- Implementing user login/logout
- Managing JWT tokens and refresh tokens
- Implementing OAuth 2.0 flows
- Hashing and validating passwords
- Creating password reset flows
- Implementing API keys
- Managing user sessions
- Implementing multi-factor authentication (MFA)
- Role-based access control (RBAC)

## JWT Authentication

**Generate and verify tokens:**

```typescript
// services/auth.service.ts
import jwt from 'jsonwebtoken';
import bcrypt from 'bcrypt';

export interface TokenPayload {
  userId: string;
  email: string;
  roles: string[];
}

export class AuthService {
  private jwtSecret = process.env.JWT_SECRET!;
  private refreshSecret = process.env.REFRESH_TOKEN_SECRET!;

  // Generate access token (15 minutes)
  generateAccessToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.jwtSecret, {
      expiresIn: '15m'
    });
  }

  // Generate refresh token (7 days)
  generateRefreshToken(payload: TokenPayload): string {
    return jwt.sign(payload, this.refreshSecret, {
      expiresIn: '7d'
    });
  }

  // Verify access token
  verifyAccessToken(token: string): TokenPayload {
    try {
      return jwt.verify(token, this.jwtSecret) as TokenPayload;
    } catch (error) {
      throw new UnauthorizedError('Invalid token');
    }
  }

  // Verify refresh token and issue new access token
  refreshAccessToken(refreshToken: string): string {
    try {
      const payload = jwt.verify(
        refreshToken,
        this.refreshSecret
      ) as TokenPayload;

      return this.generateAccessToken(payload);
    } catch (error) {
      throw new UnauthorizedError('Invalid refresh token');
    }
  }

  // Hash password with bcrypt (async - 10 rounds)
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10);
  }

  // Verify password
  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }
}
```

**Login endpoint:**

```typescript
export class AuthController {
  constructor(
    private authService: AuthService,
    private userRepository: UserRepository
  ) {}

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const { email, password } = req.body;

      // Find user
      const user = await this.userRepository.findByEmail(email);
      if (!user) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Verify password
      const isValid = await this.authService.verifyPassword(
        password,
        user.password
      );
      if (!isValid) {
        return res.status(401).json({ error: 'Invalid credentials' });
      }

      // Generate tokens
      const accessToken = this.authService.generateAccessToken({
        userId: user.id,
        email: user.email,
        roles: user.roles
      });

      const refreshToken = this.authService.generateRefreshToken({
        userId: user.id,
        email: user.email,
        roles: user.roles
      });

      // Store refresh token (in database or Redis)
      await this.userRepository.storeRefreshToken(user.id, refreshToken);

      // Set secure HTTP-only cookie
      res.cookie('refreshToken', refreshToken, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
      });

      res.json({
        accessToken,
        user: {
          id: user.id,
          email: user.email,
          name: user.name
        }
      });
    } catch (error) {
      next(error);
    }
  }

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const refreshToken = req.cookies.refreshToken;

      if (!refreshToken) {
        return res.status(401).json({ error: 'No refresh token' });
      }

      const accessToken = this.authService.refreshAccessToken(refreshToken);

      res.json({ accessToken });
    } catch (error) {
      res.status(401).json({ error: 'Invalid refresh token' });
    }
  }

  async logout(req: Request, res: Response) {
    const userId = req.user?.userId;

    // Invalidate refresh token in database
    if (userId) {
      await this.userRepository.invalidateRefreshToken(userId);
    }

    // Clear cookie
    res.clearCookie('refreshToken');

    res.json({ message: 'Logged out' });
  }
}
```

## Password Reset Flow

```typescript
export class PasswordResetService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService,
    private crypto: typeof import('crypto')
  ) {}

  async requestReset(email: string): Promise<void> {
    const user = await this.userRepository.findByEmail(email);

    // Send email even if user not found (security)
    if (!user) {
      return;
    }

    // Generate token (32 random bytes)
    const token = this.crypto.randomBytes(32).toString('hex');
    const hashedToken = this.crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Store hashed token with expiry (1 hour)
    await this.userRepository.storePasswordResetToken(
      user.id,
      hashedToken,
      new Date(Date.now() + 60 * 60 * 1000)
    );

    // Send email with reset link
    const resetUrl = `https://example.com/reset-password?token=${token}`;
    await this.emailService.sendPasswordResetEmail(user.email, resetUrl);
  }

  async resetPassword(token: string, newPassword: string): Promise<void> {
    // Hash token to compare with stored value
    const hashedToken = this.crypto
      .createHash('sha256')
      .update(token)
      .digest('hex');

    // Find user with matching token and valid expiry
    const user = await this.userRepository.findByPasswordResetToken(
      hashedToken
    );

    if (!user) {
      throw new UnauthorizedError('Invalid or expired reset token');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password and clear token
    await this.userRepository.update(user.id, {
      password: hashedPassword,
      passwordResetToken: null,
      passwordResetExpires: null
    });
  }
}
```

## OAuth 2.0 Google Strategy

```typescript
// config/passport.ts
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';

passport.use(
  new GoogleStrategy(
    {
      clientID: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
      callbackURL: '/api/auth/google/callback'
    },
    async (accessToken, refreshToken, profile, done) => {
      try {
        // Find or create user
        let user = await userRepository.findByGoogleId(profile.id);

        if (!user) {
          user = await userRepository.create({
            googleId: profile.id,
            email: profile.emails[0].value,
            name: profile.displayName,
            avatar: profile.photos[0]?.value
          });
        }

        done(null, user);
      } catch (error) {
        done(error);
      }
    }
  )
);

passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser(async (id, done) => {
  try {
    const user = await userRepository.findById(id);
    done(null, user);
  } catch (error) {
    done(error);
  }
});

// Routes
app.get(
  '/api/auth/google',
  passport.authenticate('google', { scope: ['profile', 'email'] })
);

app.get(
  '/api/auth/google/callback',
  passport.authenticate('google', { failureRedirect: '/login' }),
  (req, res) => {
    // Generate tokens for authenticated user
    const user = req.user as User;
    const accessToken = authService.generateAccessToken({
      userId: user.id,
      email: user.email,
      roles: user.roles
    });

    res.redirect(`/dashboard?token=${accessToken}`);
  }
);
```

## API Key Authentication

```typescript
// middleware/api-key.middleware.ts
import crypto from 'crypto';

export class ApiKeyService {
  async generateApiKey(): Promise<{ key: string; hash: string }> {
    const key = crypto.randomBytes(32).toString('hex');
    const hash = crypto
      .createHash('sha256')
      .update(key)
      .digest('hex');

    return { key, hash };
  }

  async validateApiKey(key: string): Promise<string | null> {
    const hash = crypto
      .createHash('sha256')
      .update(key)
      .digest('hex');

    const apiKey = await apiKeyRepository.findByHash(hash);
    return apiKey?.projectId || null;
  }
}

// Middleware
export const apiKeyAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const apiKey = req.headers['x-api-key'] as string;

  if (!apiKey) {
    return res.status(401).json({ error: 'API key required' });
  }

  const projectId = await apiKeyService.validateApiKey(apiKey);

  if (!projectId) {
    return res.status(401).json({ error: 'Invalid API key' });
  }

  req.projectId = projectId;
  next();
};

// Usage
app.post('/api/events', apiKeyAuth, createEvent);
```

## Role-Based Access Control (RBAC)

```typescript
// types/rbac.ts
export type Role = 'user' | 'moderator' | 'admin';

export const ROLE_PERMISSIONS: Record<Role, string[]> = {
  user: ['read:own_profile', 'update:own_profile'],
  moderator: [
    'read:own_profile',
    'update:own_profile',
    'read:all_users',
    'moderate:content'
  ],
  admin: ['*'] // All permissions
};

// middleware/rbac.middleware.ts
export const requirePermission = (permission: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }

    const userPermissions = req.user.roles.flatMap(
      role => ROLE_PERMISSIONS[role] || []
    );

    const hasPermission =
      userPermissions.includes('*') ||
      userPermissions.includes(permission);

    if (!hasPermission) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }

    next();
  };
};

// Usage
app.delete(
  '/api/users/:id',
  authenticate,
  requirePermission('delete:users'),
  deleteUser
);
```

## Multi-Factor Authentication (MFA)

```typescript
import speakeasy from 'speakeasy';
import qrcode from 'qrcode';

export class MFAService {
  // Generate TOTP secret
  generateSecret(email: string) {
    return speakeasy.generateSecret({
      name: `My App (${email})`,
      issuer: 'My App',
      length: 32
    });
  }

  // Generate QR code
  async generateQRCode(secret: string): Promise<string> {
    return qrcode.toDataURL(secret);
  }

  // Verify TOTP token
  verifyToken(secret: string, token: string): boolean {
    return speakeasy.totp.verify({
      secret,
      encoding: 'base32',
      token,
      window: 2 // Allow 2 token windows (30 seconds each)
    });
  }
}

// Enable MFA endpoint
app.post('/api/mfa/enable', authenticate, async (req, res) => {
  const secret = mfaService.generateSecret(req.user.email);
  const qrCode = await mfaService.generateQRCode(secret.otpauth_url!);

  // Store temporary secret (not yet verified)
  await userRepository.storeTemporaryMFA(req.user.userId, secret.base32);

  res.json({
    qrCode,
    secret: secret.base32, // For manual entry
    message: 'Scan QR code with authenticator app'
  });
});

// Verify TOTP token
app.post('/api/mfa/verify', authenticate, async (req, res) => {
  const { token } = req.body;
  const tempSecret = await userRepository.getTemporaryMFA(req.user.userId);

  if (!tempSecret || !mfaService.verifyToken(tempSecret, token)) {
    return res.status(400).json({ error: 'Invalid token' });
  }

  // Enable MFA
  await userRepository.enableMFA(req.user.userId, tempSecret);
  res.json({ message: 'MFA enabled' });
});

// Login with MFA
app.post('/api/login/mfa', authenticate, async (req, res) => {
  const { token } = req.body;
  const user = req.user!;

  if (!user.mfaEnabled) {
    return res.status(400).json({ error: 'MFA not enabled' });
  }

  const isValid = mfaService.verifyToken(user.mfaSecret, token);

  if (!isValid) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  // Issue tokens after MFA verification
  const accessToken = authService.generateAccessToken({
    userId: user.id,
    email: user.email,
    roles: user.roles
  });

  res.json({ accessToken });
});
```

## Best Practices

1. **Never store plain passwords** - Always hash with bcrypt
2. **Use HTTPS** - Always in production
3. **Set HTTP-only cookies** - Prevent XSS token theft
4. **Implement refresh tokens** - Short-lived access tokens
5. **Rate limit auth endpoints** - Prevent brute force
6. **Validate input strictly** - Especially passwords
7. **Use secure random tokens** - `crypto.randomBytes()`
8. **Handle token expiration** - Gracefully redirect to login
9. **Implement logout** - Invalidate tokens server-side
10. **Audit auth events** - Log all login/logout/failures

## Security Checklist

- [ ] Passwords hashed with bcrypt (10+ rounds)
- [ ] JWT secrets secure and long (32+ characters)
- [ ] Refresh tokens stored securely
- [ ] HTTPS enforced in production
- [ ] CORS properly configured
- [ ] Rate limiting on auth endpoints
- [ ] Password reset tokens expire (1 hour)
- [ ] MFA supported for sensitive operations
- [ ] Auth events logged and monitored
- [ ] Sensitive data not logged

## See Also

- middleware-patterns - Auth middleware implementation
- database-integration - Storing user credentials
- testing-patterns - Testing auth flows
