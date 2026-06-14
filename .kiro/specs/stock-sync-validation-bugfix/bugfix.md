# Stock Sync and Validation Bugfix Requirements Document

## Introduction

This document addresses two critical bugs in the Flutter pharmacy app's stock management system that compromise data integrity and user experience:

**BUG 1: Stock Not Syncing After Edit** - When an admin successfully updates medicine stock via the "Edit Data Obat" screen, the API returns success (HTTP 200), but other screens (particularly petugas/E-Resep) continue to display outdated stock values. This creates inconsistency across the application and can lead to incorrect prescription decisions.

**BUG 2: Stock Not Validated Before Saving Prescription** - When petugas creates a prescription (E-Resep) with quantities exceeding available stock, the system allows the save operation without validation. The stock is not decremented, and no error is shown to the user, creating silent failures and potential fulfillment issues.

These bugs affect critical pharmacy workflows, potentially leading to incorrect inventory tracking, unfulfillable prescriptions, and poor user experience. The root causes appear to be related to provider cache invalidation and missing validation logic.

## Bug Analysis

### Current Behavior (Defect)

#### Bug 1: Stock Sync Failure

1.1 WHEN admin edits medicine stock via "Edit Data Obat" screen and saves successfully (API returns 200) THEN the petugas E-Resep screens still display the old stock value instead of the updated value

1.2 WHEN admin updates stock from 50 to 20 for a medicine THEN the ObatProvider cache in petugas screens is not refreshed and continues showing stock as 50

1.3 WHEN admin edits medicine data in edit_obat.dart and receives API success response THEN other provider instances (in different screens/contexts) do not receive the updated data

#### Bug 2: Missing Stock Validation

1.4 WHEN petugas inputs prescription quantity (e.g., 30) that exceeds available stock (e.g., 20) in E-Resep form THEN the system allows the save operation to proceed without showing validation error

1.5 WHEN prescription is saved with quantity > available stock THEN the admin-side stock value remains unchanged (not decremented) and no error feedback is provided to petugas

1.6 WHEN createResep is called in ResepService THEN no stock availability check is performed before submitting the prescription to the API

### Expected Behavior (Correct)

#### Bug 1: Stock Sync Fix

2.1 WHEN admin edits medicine stock via "Edit Data Obat" screen and saves successfully THEN the system SHALL immediately refresh the ObatProvider cache to reflect the updated stock value

2.2 WHEN admin updates stock for a medicine THEN all screens displaying that medicine's stock (including petugas E-Resep screens) SHALL show the updated value within the next data fetch or refresh

2.3 WHEN updateObat succeeds in ObatService THEN the ObatProvider SHALL update its local cache AND notify all listeners so dependent UI components re-render with fresh data

#### Bug 2: Stock Validation Fix

2.4 WHEN petugas inputs prescription quantity that exceeds available stock THEN the system SHALL display a validation error message and prevent the save operation

2.5 WHEN prescription form is submitted THEN the system SHALL check each medicine's requested quantity against current available stock before calling createResep API

2.6 WHEN stock validation fails (quantity > available stock) THEN the system SHALL show a clear error message identifying which medicines have insufficient stock and the available quantities

### Unchanged Behavior (Regression Prevention)

#### General Stock Management

3.1 WHEN admin edits medicine data that does NOT include stock changes (e.g., only name or category) THEN the system SHALL CONTINUE TO save successfully and update the cache as before

3.2 WHEN petugas creates prescription with quantities within available stock limits THEN the system SHALL CONTINUE TO save successfully without validation errors

3.3 WHEN ObatProvider.fetchObat() is called manually (e.g., pull-to-refresh) THEN the system SHALL CONTINUE TO fetch fresh data from API and update the cache

#### UI Display and Navigation

3.4 WHEN admin views the medicine list in daftar_obat.dart THEN the system SHALL CONTINUE TO display medicines with their current stock values from the provider cache

3.5 WHEN petugas navigates between E-Resep screens THEN the system SHALL CONTINUE TO maintain form state and navigation flow as before

3.6 WHEN API calls fail (network error, server error) THEN the system SHALL CONTINUE TO display appropriate error messages as before

#### Filtering and Search

3.7 WHEN admin or petugas uses search or filter functionality THEN the system SHALL CONTINUE TO filter based on the cached data without triggering unnecessary API calls
