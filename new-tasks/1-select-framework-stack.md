# Task 1: Framework Setup and Architecture

**Feature**: none
**Created**: 2025-09-30

## Problem
Build the foundational framework for a real-time chat application with AI streaming, authentication, and the retro terminal design system.

## Success Criteria
- [ ] Initialize Next.js 14 project with TypeScript
- [ ] Configure PostgreSQL database with Prisma ORM
- [ ] Set up authentication system with magic links and OAuth capability
- [ ] Implement Vercel AI SDK for streaming chat
- [ ] Apply retro terminal design system from /docs/design/
- [ ] Deploy to Vercel with CI/CD pipeline

## Technology Stack

### Core Framework
- **Next.js 14** (App Router)
- **TypeScript** (strict mode)
- **PostgreSQL** + **Prisma ORM**
- **Vercel** deployment

### Authentication
- **Clerk** (if budget allows) OR
- **Auth.js v5** (free alternative)

### AI & Streaming
- **Vercel AI SDK**
- **OpenAI** or **Groq** API

### Styling
- **CSS Modules** with design system variables
- Terminal aesthetic from `/docs/design/DESIGN_SYSTEM.md`

## Implementation Steps

1. **Project Setup**
   ```bash
   npx create-next-app@latest the-ask --typescript --app --no-tailwind
   cd the-ask
   npm install prisma @prisma/client
   npm install ai openai
   ```

2. **Database Schema**
   - Users table (id, email, name)
   - Sessions table (authentication)
   - Messages table (chat history)
   - Asks/Offers tables (core features)

3. **Authentication Flow**
   - Magic link email verification
   - Session management
   - Protected routes middleware

4. **Chat Interface**
   - Message streaming with typewriter effect
   - Retro terminal UI components
   - Real-time updates

5. **Deployment**
   - Environment variables configuration
   - Vercel project setup
   - Automatic deployments from main branch

---

<!--
Workflow Reminder:
1. Start in work/tasks/backlog/
2. Move to work/tasks/next/ during sprint planning
3. Move to work/tasks/working/ when starting work
4. Move to work/tasks/review/ when complete
5. Move to work/tasks/live/ after approval

If blocked, move back to work/tasks/next/
-->