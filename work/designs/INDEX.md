# Designs

## Overview

This directory contains all design-related assets and documentation, including UI/UX designs, wireframes, mockups, and visual specifications. It serves as the central repository for the project's visual and interaction design.

## Usage

Use this directory to store and manage all design assets. Refer to the existing design documents for guidance on the project's visual style and user experience.

# Design Documentation

Storage for UI/UX designs, wireframes, mockups, and visual specifications.

## Purpose

This folder contains all design-related assets and documentation that guide the visual and interaction aspects of the project.

## Organization

### File Types
- **Mockups** - High-fidelity designs (.png, .jpg, .pdf)
- **Wireframes** - Low-fidelity structural layouts
- **Prototypes** - Interactive design files (.fig, .sketch, .xd)
- **Style Guides** - Color, typography, spacing documentation
- **User Flows** - Interaction and navigation diagrams

### Naming Convention
```
[component]-[type]-[version].[ext]
```

Examples:
- `dashboard-mockup-v1.png`
- `login-wireframe-v2.pdf`
- `navigation-userflow-v1.md`
- `buttons-styleguide.md`

## Design File Format (Markdown)

For design documentation in markdown:

```markdown
# Component/Feature Name

## Design Goals
What this design aims to achieve

## User Stories
- As a user, I want to...
- As an admin, I need to...

## Visual Specifications
- Colors: #hex codes
- Typography: Font families and sizes
- Spacing: Margin and padding values

## Interaction States
- Default
- Hover
- Active
- Disabled

## Responsive Breakpoints
- Mobile: < 768px
- Tablet: 768px - 1024px
- Desktop: > 1024px

## Accessibility Notes
- WCAG compliance level
- Keyboard navigation
- Screen reader considerations

## Implementation Notes
Technical considerations for developers
```

## Linking Designs to Tasks

Reference designs in task files:
```markdown
# Task: Implement Dashboard

## Design Reference
See: work/designs/dashboard-mockup-v2.png

## Requirements
Based on design specifications...
```

## Version Control

### Binary Files
For image files and design documents:
- Use version numbers in filenames
- Keep only current and previous version
- Archive older versions periodically

### Text-Based Designs
For markdown and text files:
- Track normally with git
- Use meaningful commit messages
- Reference related task IDs

## Tools & Formats

### Recommended Tools
- **Figma** - Collaborative design
- **Sketch** - macOS design tool
- **Adobe XD** - Prototyping
- **Excalidraw** - Quick diagrams
- **Draw.io** - Flow charts

### Export Formats
- **PNG** - Mockups and final designs
- **SVG** - Icons and scalable graphics
- **PDF** - Print-ready or review documents
- **MD** - Design specifications and documentation

## Design Review Process

1.  Create design in appropriate tool
2.  Export to reviewable format (PNG/PDF)
3.  Place in `/work/designs/`
4.  Reference in related task
5.  Link in feature documentation
6.  Update after review feedback

## Best Practices

1.  **Keep files small** - Optimize images
2.  **Use clear names** - Component and version obvious
3.  **Document decisions** - Why, not just what
4.  **Consider accessibility** - From the start
5.  **Mobile-first** - Design for small screens first
6.  **Version control** - Track changes systematically

## Quick Commands

```bash
# List all designs
ls work/designs/

# Find designs for specific component
ls work/designs/*dashboard*

# Check design file sizes
du -h work/designs/*

# Open design (macOS)
open work/designs/dashboard-mockup-v2.png