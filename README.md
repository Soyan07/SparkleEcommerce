# Project Overview & Structure Guide

## Purpose of This Document

This document explains the overall project structure, file organization, and UI-related functionalities in a simple and clear way.
It is designed so that any new developer can understand the project just by reading this guide, without facing confusion about files, folders, or page logic.

This project is **UI and frontend-structure focused only**.
There is no dependency on database, backend logic, or system configuration.

---

## Root Directory Overview

The root directory contains all core folders and files required to run and understand the project.

**Main responsibilities of the root directory:**
*   Entry point of the application
*   Page routing and navigation
*   Controller bindings
*   UI assets (styles, images, components)

Each folder and file is named clearly to reflect its responsibility.

---

## Controllers Overview

### HomeController

The `HomeController` is responsible for handling all logic related to the **Home Page UI**.

**Functionalities handled inside HomeController:**
*   Home page layout logic
*   Navigation handling
*   UI state management
*   Event handling for buttons and interactions

**Key responsibilities include:**
*   Loading the Home Page design
*   Managing UI-based actions (no backend logic)
*   Handling page transitions (if applicable)

---

## Page & UI Design Locations

### Home Page Design

The Home Page UI design is stored in its dedicated view/page file:
`Sparkle.Api/Views/Home/Index.cshtml`

**This file contains:**
*   Layout structure
*   Components arrangement
*   Styling references

### Add To Gallery Page

The AddToGallery page (mapped to `Sparkle.Api/Views/Home/Product.cshtml`) has its own separate file.

**This ensures:**
*   Clean separation of concerns
*   Easy maintenance and updates
*   The page focuses only on UI and user interaction

---

## UI Features & Customization

### Color Change Functionality

Color-related logic is placed in a dedicated UI helper or component (`Sparkle.Api/wwwroot/css/site.css` / `Sparkle.Api/wwwroot/js/site.js`).

**This keeps styling changes:**
*   Centralized
*   Easy to update
*   Consistent across the application

### Assets & Styling

All images, icons, and visual assets are stored in an **assets folder** (`Sparkle.Api/wwwroot/`).

**Styling files (CSS / theme / styles):**
*   Are well-organized
*   Follow a consistent naming convention
*   Are reusable across pages

---

## File Naming & Format Guidelines

*   File names clearly describe their purpose
*   Folder structure follows logical grouping
*   Code and files are organized to be:
    *   Readable
    *   Scalable
    *   Easy to debug

---

## Developer Guideline

If a developer joins the company:
1.  They can understand the full project by reviewing this structure
2.  They can quickly identify:
    *   Where each page is designed
    *   Which controller manages which functionality
    *   Where UI customizations are handled

**This structure ensures:**
*   No confusion
*   Faster onboarding
*   Clean and professional project presentation

---

## Scope of This Project

*   **UI & frontend structure only**
*   No database integration
*   No backend logic
*   No system-level dependency
*   The goal is **visual clarity, clean structure, and easy understanding**.
