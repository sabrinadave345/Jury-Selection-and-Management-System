# Jury Selection and Management System

A comprehensive blockchain-based jury management system built with Clarity smart contracts for transparent, fair, and efficient jury selection and administration.

## System Overview

This system provides a complete solution for managing jury duty from citizen registration through case completion, ensuring transparency, fairness, and proper compensation.

### Core Components

1. **Citizen Registry** (`citizen-registry.clar`)
    - Citizen registration and eligibility verification
    - Background check status tracking
    - Demographic information management

2. **Jury Selection** (`jury-selection.clar`)
    - Random jury selection algorithms
    - Pool management and availability tracking
    - Conflict of interest screening

3. **Case Management** (`case-management.clar`)
    - Case creation and assignment
    - Jury panel formation
    - Case status tracking

4. **Scheduling System** (`scheduling.clar`)
    - Availability management
    - Court date coordination
    - Notification system

5. **Compensation Tracker** (`compensation.clar`)
    - Service fee calculation
    - Payment processing
    - Expense reimbursement

## Key Features

- **Transparent Selection**: Blockchain-based random selection ensures fairness
- **Automated Screening**: Built-in conflict of interest detection
- **Flexible Scheduling**: Citizens can manage their availability
- **Fair Compensation**: Automated calculation and tracking of jury fees
- **Performance Tracking**: Evaluation system for continuous improvement

## Smart Contract Architecture

### Data Structures

- **Citizens**: Registration status, eligibility, demographics
- **Cases**: Case details, required jury size, status
- **Jury Pools**: Selected citizens for specific cases
- **Schedules**: Availability windows and court dates
- **Compensation**: Service fees and payment status

### Access Control

- **Admin Functions**: Case creation, system configuration
- **Citizen Functions**: Registration, availability updates
- **Court Functions**: Jury selection, case management

## Usage

### For Citizens
1. Register with the system
2. Complete eligibility verification
3. Set availability preferences
4. Receive selection notifications
5. Serve on assigned cases
6. Receive compensation

### For Court Administrators
1. Create new cases
2. Specify jury requirements
3. Initiate selection process
4. Manage court schedules
5. Process compensation

### For System Administrators
1. Configure system parameters
2. Manage citizen eligibility
3. Monitor system performance
4. Handle appeals and exceptions

## Testing

The system includes comprehensive tests using Vitest:

\`\`\`bash
npm test
\`\`\`

## Configuration

- `Clarinet.toml`: Clarinet project configuration
- `package.json`: Node.js dependencies and scripts

## Security Considerations

- All sensitive operations require proper authorization
- Random selection uses blockchain entropy for fairness
- Compensation calculations are transparent and auditable
- Personal information is handled with privacy protections
