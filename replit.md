# Overview

A comprehensive financial portfolio tracking application built with React and Express.js. The application allows users to manage investment portfolios, track assets (stocks, crypto, commodities, ETFs), record financial transactions, monitor income and expenses, and generate detailed reports. The system uses a mobile-first design approach optimized for smartphone usage with a clean, modern interface.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture
- **Framework**: React 18 with TypeScript and Vite for fast development
- **UI Library**: shadcn/ui components built on Radix UI primitives
- **Styling**: Tailwind CSS with custom design system and CSS variables
- **State Management**: TanStack Query (React Query) for server state management
- **Routing**: Wouter for lightweight client-side routing
- **Form Handling**: React Hook Form with Zod validation schemas
- **Charts**: Recharts for data visualization and financial charts

### Backend Architecture
- **Framework**: Express.js with TypeScript for REST API
- **Database ORM**: Drizzle ORM for type-safe database operations
- **Build System**: ESBuild for server bundling and production builds
- **Development**: tsx for TypeScript execution in development

### Data Storage Solutions
- **Database**: PostgreSQL with connection pooling via Neon serverless
- **Schema Management**: Drizzle migrations with structured schema definitions
- **Data Models**: Comprehensive financial entities including users, assets, portfolios, transactions, income/expense records

### Mobile-First Design
- **Layout**: Bottom navigation pattern optimized for thumb navigation
- **Responsive**: Max-width container design centered for mobile devices
- **Components**: Touch-friendly interface elements with proper spacing
- **Typography**: Inter font family for excellent mobile readability

### Financial Data Architecture
- **Asset Categories**: Organized structure for stocks, crypto, commodities, ETFs, and funds
- **Portfolio Management**: Real-time value tracking with profit/loss calculations
- **Transaction System**: Complete buy/sell transaction recording with fees
- **Income/Expense Tracking**: Categorized financial record management
- **Currency Support**: Multi-currency support with conversion capabilities

## External Dependencies

### Database Services
- **Neon Database**: PostgreSQL serverless database with connection pooling
- **Drizzle Kit**: Database migration and schema management toolkit

### Financial Data APIs
- **Alpha Vantage**: Stock market data and real-time price feeds
- **Exchange Rate API**: Currency conversion and exchange rate data
- **Cryptocurrency APIs**: Digital asset price tracking and market data

### Development Tools
- **Replit Integration**: Development environment optimization with Cartographer
- **Vite Plugins**: Runtime error handling and development tooling
- **PostCSS**: CSS processing with Tailwind and Autoprefixer

### UI/UX Libraries
- **Radix UI**: Accessible component primitives for complex UI elements
- **Lucide Icons**: Comprehensive icon library for modern interfaces
- **FontAwesome**: Additional icon support for financial symbols
- **Class Variance Authority**: Utility for creating variant-based component APIs

### Form and Validation
- **React Hook Form**: Performance-optimized form state management
- **Zod**: TypeScript-first schema validation library
- **Hookform Resolvers**: Integration between React Hook Form and Zod

### Data Visualization
- **Recharts**: Responsive chart library for portfolio performance visualization
- **Embla Carousel**: Touch-friendly carousel component for mobile interfaces

### Development Dependencies
- **TypeScript**: Static type checking and enhanced developer experience
- **ESLint**: Code quality and consistency enforcement
- **Prettier**: Code formatting and style consistency