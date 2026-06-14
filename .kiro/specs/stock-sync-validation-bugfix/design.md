# Stock Sync and Validation Bugfix Design

## Overview

This design addresses two critical bugs in the pharmacy app's stock management system:

**BUG 1: Stock Cache Synchronization Failure** - When admin successfully updates medicine stock via `edit_obat.dart`, the ObatProvider cache in other parts of the application (particularly petugas E-Resep screens) is not refreshed, causing stale data to be displayed. This occurs because the edit screen directly calls `ObatService.updateObat()` but does not notify the ObatProvider instance used by other screens.

**BUG 2: Missing Stock Validation Before Prescription Save** - When petugas creates a prescription in `detail_eresep.dart`, there is no validation to check if the requested quantities exceed available stock before saving. The current validation only checks against the prescription's requested quantity and displays stock information, but doesn't prevent saving when stock is insufficient.

**Fix Approach**:
- For BUG 1: Implement cache refresh mechanism in ObatProvider after successful stock updates
- For BUG 2: Add pre-save stock validation in EResepProvider.addResep() method

## Glossary

- **Bug_Condition_1 (C1)**: Admin updates stock via edit_obat.dart → API returns 200 → ObatProvider cache in other contexts not refreshed
- **Bug_Condition_2 (C2)**: Petugas inputs prescription quantities > available stock → save proceeds without validation error
- **Property (P1)**: After successful stock update, all ObatProvider instances SHALL reflect updated stock values
- **Property (P2)**: Prescription save SHALL be blocked if any medicine quantity exceeds available stock
- **Preservation**: Stock updates within available limits, non-stock medicine edits, and UI navigation SHALL remain unchanged
- **ObatProvider**: Provider class managing medicine data cache with ChangeNotifier pattern (lib/providers/provider_obat.dart)
- **EResepProvider**: Provider class managing prescription data (lib/providers/provider_eresep.dart)
- **ObatService**: Service class handling medicine API operations (lib/services/service_obat.dart)
- **ResepService**: Service class handling prescription API operations (lib/services/service_resep.dart)
- **edit_obat.dart**: Admin screen for editing medicine data including stock
- **detail_eresep.dart**: Petugas screen for creating prescriptions with medicine selection
- **Provider Instance Isolation**: Different screens may use separate ObatProvider instances if not properly configured with Provider scope
- **Cache Invalidation**: The process of refreshing stale data in a provider's local cache

## Bug Details

### Bug Condition 1: Stock Cache Synchronization

The first bug manifests when an admin updates medicine stock through the edit screen, but the updated stock value is not reflected in other parts of the application (specifically petugas E-Resep screens).

**Formal Specification:**
```
FUNCTION isBugCondition1(input)
  INPUT: input of type StockUpdateEvent
  OUTPUT: boolean
  
  RETURN input.screenType == 'edit_obat.dart'
         AND input.apiResponse.statusCode == 200
         AND input.updateType INCLUDES 'stock_change'
         AND observerScreen.providerInstance != editorScreen.providerInstance
         AND NOT observerScreen.obatProvider.cacheRefreshed
END FUNCTION
```

**Concrete Examples:**
- Admin edits "Cefadroxil 500mg" stock from 80 to 50 via edit_obat.dart → API returns 200 → Petugas viewing detail_eresep.dart still sees stock as 80
- Admin updates "Paracetamol" stock from 100 to 20 → Save succeeds → daftar_eresep.dart displays cached value 100 instead of 20
- Admin increases "Amoxicillin" stock from 30 to 100 → Other screens show outdated stock until manual refresh

### Bug Condition 2: Missing Stock Validation

The second bug manifests when petugas creates a prescription with quantities exceeding available stock, but the system allows the save operation without validation.

**Formal Specification:**
```
FUNCTION isBugCondition2(input)
  INPUT: input of type PrescriptionSaveRequest
  OUTPUT: boolean
  
  RETURN EXISTS medicine IN input.prescriptionItems WHERE
         (medicine.requestedQuantity > medicine.availableStock)
         AND input.validationResult == 'not_performed'
         AND input.saveAttempt == true
END FUNCTION
```

**Concrete Examples:**
- Petugas creates prescription for "Cefadroxil 500mg" quantity 30 when stock is 20 → Save proceeds → Stock remains 20 (not decremented)
- Petugas inputs 50 units of "Mylanta" when only 10 available → No validation error shown → EResepProvider.addResep() completes successfully
- Petugas creates multi-medicine prescription where 2 medicines exceed stock → Save operation allowed without warning

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**

1. **Non-Stock Medicine Edits**: When admin edits medicine data that does NOT include stock changes (e.g., only name, category, or pricing), the system SHALL continue to save successfully and update the cache as before

2. **Valid Prescription Creation**: When petugas creates prescription with quantities within available stock limits, the system SHALL continue to save successfully without validation errors

3. **Manual Refresh Functionality**: When ObatProvider.fetchObat() is called manually (e.g., pull-to-refresh gesture), the system SHALL continue to fetch fresh data from API and update the cache

4. **Search and Filter Operations**: When admin or petugas uses search or filter functionality, the system SHALL continue to filter based on cached data without triggering unnecessary API calls

5. **Error Handling**: When API calls fail (network error, server error), the system SHALL continue to display appropriate error messages as before

6. **UI Navigation**: When petugas navigates between E-Resep screens, the system SHALL continue to maintain form state and navigation flow as before

**Scope:**

All inputs that do NOT involve the specific bug conditions (stock update cache invalidation and pre-save stock validation) should be completely unaffected by this fix. This includes:
- Medicine list display and filtering
- Prescription status updates
- Other CRUD operations on medicines and prescriptions
- User authentication and authorization flows

## Hypothesized Root Cause

Based on analysis of the codebase, the most likely root causes are:

### Bug 1: Stock Cache Synchronization Failure

**1. Provider Instance Isolation Issue**

The edit_obat.dart screen directly instantiates ObatService and calls updateObat() without interacting with the ObatProvider:

```dart
// In edit_obat.dart line 38-39
final _obatService = ObatService();
// ...
final result = await _obatService.updateObat(widget.obat.idObat, _updatedObat!);
```

This bypasses the ObatProvider completely. The ObatProvider has an updateObat() method (line 140-160 in provider_obat.dart) that properly updates the cache and notifies listeners, but it's not being used by the edit screen.

**2. No Cross-Provider Communication Mechanism**

Even if the edit screen's ObatService call succeeds, there's no mechanism to notify other ObatProvider instances (used by petugas screens) that the data has changed. The Provider pattern relies on notifyListeners(), but only affects widgets listening to that specific provider instance.

**3. Missing Cache Invalidation After API Success**

The edit_obat.dart screen successfully updates the API but returns to the previous screen without triggering a cache refresh. The calling screen has no way to know that it should refetch data.

### Bug 2: Missing Stock Validation

**1. No Pre-Save Validation in addResep() Method**

The EResepProvider.addResep() method (line 138-157 in provider_eresep.dart) directly calls ResepService.createResep() without any stock validation:

```dart
// Current implementation - NO stock check
Future<void> addResep(Resep resep) async {
  // ... fallback logic ...
  try {
    final newResep = await _resepService.createResep(resep);
    // No validation of stock availability
```
    _resepList.insert(0, newResep);
    notifyListeners();
  } catch (e) { ... }
}
```

**2. UI-Level Validation is Insufficient**

The detail_eresep.dart screen has UI-level validation (line 243-255 `_validasiStok()`) that checks stock before save, but this validation can be bypassed or may not have access to real-time stock data if the ObatProvider cache is stale.

**3. Missing Stock Check in Service Layer**

The ResepService.createResep() method (service_resep.dart lines 42-61) directly posts to the API without checking stock availability. There's no business logic layer enforcing stock constraints.

## Correctness Properties

Property 1: Bug Condition 1 - Stock Cache Synchronization

_For any_ stock update operation where admin successfully saves stock changes via edit_obat.dart (API returns HTTP 200), the system SHALL immediately refresh all ObatProvider instances throughout the application, ensuring that any screen displaying medicine stock (including petugas E-Resep screens) reflects the updated stock value within the next render cycle.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Bug Condition 2 - Pre-Save Stock Validation

_For any_ prescription save operation where one or more medicine quantities exceed available stock, the EResepProvider.addResep() method SHALL throw a validation exception with clear error messages identifying which medicines have insufficient stock and their available quantities, preventing the API call from executing.

**Validates: Requirements 2.4, 2.5, 2.6**

Property 3: Preservation - Non-Stock Medicine Operations

_For any_ medicine edit operation that does NOT involve stock changes (e.g., name, category, pricing updates only), the system SHALL produce exactly the same behavior as the original code, successfully saving changes and updating the cache without triggering unnecessary stock synchronization logic.

**Validates: Requirements 3.1, 3.7**

Property 4: Preservation - Valid Prescription Creation

_For any_ prescription save operation where all medicine quantities are within available stock limits, the system SHALL produce exactly the same behavior as the original code, successfully creating the prescription without validation errors or blocking.

**Validates: Requirements 3.2, 3.3**

## Fix Implementation

### Changes Required for Bug 1: Stock Cache Synchronization

Assuming our root cause analysis is correct:


**File 1**: `lib/pages/admin/edit_obat.dart`

**Changes**:

1. **Replace Direct Service Call with Provider Method**:
   - Remove direct ObatService instantiation and call
   - Use `context.read<ObatProvider>().updateObat()` instead
   - This ensures cache is updated and listeners are notified

2. **Pass Updated ObatModel Back via Navigator**:
   - Continue returning updated ObatModel through Navigator.pop()
   - Calling screen can use this as confirmation

**Implementation**:
```dart
// BEFORE (current - line 38-39, 164-167):
final _obatService = ObatService();
// ...
final result = await _obatService.updateObat(widget.obat.idObat, _updatedObat!);
_updatedObat = result;

// AFTER (proposed):
// Remove _obatService field
// In _simpan() method:
final provider = context.read<ObatProvider>();
await provider.updateObat(_updatedObat!);
// ObatProvider.updateObat() already updates cache and notifies
```

**File 2**: `lib/providers/provider_obat.dart`


**Changes**:

1. **Verify updateObat() Method Properly Updates Cache**:
   - Current implementation (lines 140-160) already updates local cache
   - Ensure notifyListeners() is called after successful update
   - No changes needed if current implementation is correct

2. **Ensure Proper Provider Scope**:
   - Verify ObatProvider is provided at app root level
   - All screens should use the same ObatProvider instance
   - Check main.dart or app.dart for MultiProvider configuration

**Verification**:
```dart
// Current implementation is correct (lines 140-160):
Future<void> updateObat(ObatModel obat) async {
  try {
    final updatedObat = await _obatService.updateObat(obat.idObat, obat);
    final index = _obatList.indexWhere((o) => o.idObat == obat.idObat);
    if (index != -1) {
      _obatList[index] = updatedObat;
      _filterObat(); // Updates filtered list
      notifyListeners(); // ✓ Notifies all listeners
    }
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    rethrow;
  }
}
```

### Changes Required for Bug 2: Stock Validation


**File 1**: `lib/providers/provider_eresep.dart`

**Changes**:

1. **Add Stock Validation Logic to addResep() Method**:
   - Before calling ResepService.createResep(), validate stock availability
   - Access ObatProvider to get current stock levels
   - Throw exception if any medicine quantity exceeds stock

2. **Add ObatProvider Dependency**:
   - Accept ObatProvider as parameter or use context to access it
   - Check each medicine in the prescription against available stock

**Implementation**:
```dart
// BEFORE (current - lines 138-157):
Future<void> addResep(Resep resep) async {
  // ... local fallback logic ...
  try {
    final newResep = await _resepService.createResep(resep);
    _resepList.insert(0, newResep);
    notifyListeners();
  } catch (e) { ... }
}

// AFTER (proposed):
Future<void> addResep(Resep resep, ObatProvider obatProvider) async {
  // Validate stock BEFORE API call
  final stockErrors = <String>[];
  
  for (final detail in resep.detailResep) {
    final obat = obatProvider.obatList.firstWhere(
      (o) => o.idObat == detail.idObat,
      orElse: () => throw Exception('Obat dengan ID ${detail.idObat} tidak ditemukan'),
    );
    
    if (detail.jumlah > obat.stok) {
      stockErrors.add(
        '${obat.namaObat}: diminta ${detail.jumlah}, tersedia ${obat.stok}'
      );
    }
  }
  
  if (stockErrors.isNotEmpty) {
    throw Exception('Stok tidak mencukupi:\n${stockErrors.join('\n')}');
  }
  
  // If validation passes, proceed with API call
  try {
    final newResep = await _resepService.createResep(resep);
    _resepList.insert(0, newResep);
    notifyListeners();
  } catch (e) {
    _errorMessage = e.toString().replaceAll('Exception: ', '');
    notifyListeners();
    rethrow;
  }
}
```

**File 2**: `lib/pages/petugas/detail_eresep.dart`

**Changes**:

1. **Update addResep() Call to Pass ObatProvider**:
   - Access both EResepProvider and ObatProvider
   - Pass ObatProvider to addResep() method

2. **Handle Validation Exceptions**:
   - Catch stock validation exceptions
   - Display error message to user with specific stock details

**Implementation**:
```dart
// In _eksekusiSimpan() method or wherever addResep is called:
// BEFORE:
final eresepProvider = context.read<EResepProvider>();
await eresepProvider.addResep(newResep);

// AFTER:
final eresepProvider = context.read<EResepProvider>();
final obatProvider = context.read<ObatProvider>();

try {
  await eresepProvider.addResep(newResep, obatProvider);
  // Success handling...
} catch (e) {
  if (e.toString().contains('Stok tidak mencukupi')) {
    // Show detailed stock error to user
    _showStockValidationError(e.toString());
  } else {
    // Handle other errors
    _showGeneralError(e.toString());
  }
}
```

### Alternative Implementation Approach

If modifying EResepProvider.addResep() signature causes breaking changes elsewhere:


**Option**: Keep validation in detail_eresep.dart UI layer but ensure it uses fresh stock data:

1. Before calling addResep(), refresh ObatProvider cache
2. Perform validation with guaranteed fresh data
3. Only call addResep() if validation passes

```dart
// In detail_eresep.dart:
Future<void> _onSimpan() async {
  // Refresh stock data first
  final obatProvider = context.read<ObatProvider>();
  await obatProvider.fetchObat();
  
  // Validate with fresh data
  final stockErrors = _validateStockAvailability(obatProvider);
  if (stockErrors.isNotEmpty) {
    _showStockValidationError(stockErrors);
    return;
  }
  
  // Proceed with save
  await eresepProvider.addResep(newResep);
}
```

## Testing Strategy

### Validation Approach

The testing strategy follows a two-phase approach: first, surface counterexamples that demonstrate the bugs on unfixed code, then verify the fixes work correctly and preserve existing behavior.

### Exploratory Bug Condition Checking

**Goal**: Surface counterexamples that demonstrate both bugs BEFORE implementing the fixes.
Confirm or refute the root cause analysis. If we refute, we will need to re-hypothesize.

**Test Plan for Bug 1**: Simulate admin stock update and verify cache is NOT refreshed in other providers on UNFIXED code.

**Test Cases for Bug 1**:

1. **Stock Update Cache Sync Test** (will fail on unfixed code):
   - Setup: Create two ObatProvider instances (simulating admin and petugas contexts)
   - Action: Admin provider calls updateObat() with stock change
   - Expected Failure: Petugas provider's obatList still contains old stock value
   - Demonstrates: Cache synchronization issue

2. **Cross-Screen Stock Display Test** (will fail on unfixed code):
   - Setup: Mock edit_obat.dart calling ObatService directly
   - Action: Update medicine stock via service
   - Verify: ObatProvider instance used by other screens not updated
   - Demonstrates: Provider instance isolation

3. **API Success Without Cache Update Test** (will fail on unfixed code):
   - Setup: Spy on ObatService.updateObat() API call
   - Action: Edit screen updates stock successfully (HTTP 200)
   - Verify: ObatProvider.notifyListeners() NOT called
   - Demonstrates: Missing cache invalidation

**Test Plan for Bug 2**: Create prescriptions with quantities exceeding stock on UNFIXED code.


**Test Cases for Bug 2**:

1. **No Pre-Save Validation Test** (will fail on unfixed code):
   - Setup: Create prescription with quantity 50 for medicine with stock 20
   - Action: Call EResepProvider.addResep()
   - Expected Failure: Method succeeds without throwing exception
   - Demonstrates: Missing validation logic

2. **Stock Exceeding Multiple Medicines Test** (will fail on unfixed code):
   - Setup: Prescription with 3 medicines, 2 exceed stock
   - Action: Attempt to save prescription
   - Expected Failure: Save succeeds without blocking
   - Demonstrates: Bulk validation missing

3. **UI Validation Bypass Test** (will fail on unfixed code):
   - Setup: Call addResep() directly without UI validation
   - Action: Pass prescription with insufficient stock
   - Expected Failure: Service layer accepts invalid data
   - Demonstrates: No service-level enforcement

**Expected Counterexamples**:

Bug 1:
- ObatProvider cache remains stale after successful stock update
- notifyListeners() not triggered by edit screen
- Multiple provider instances hold inconsistent data

Bug 2:
- EResepProvider.addResep() completes without stock check
- No exception thrown for quantity > available stock
- ResepService.createResep() posts to API without validation

### Fix Checking

**Goal**: Verify that for all inputs where the bug conditions hold, the fixed functions produce the expected behavior.

**Pseudocode for Bug 1 Fix Checking:**
```
FOR ALL stockUpdate WHERE isBugCondition1(stockUpdate) DO
  adminProvider.updateObat(updatedMedicine)
  
  ASSERT petugasProvider.obatList[medicineId].stok == updatedMedicine.stok
  ASSERT observerScreen receives notifyListeners() event
  ASSERT UI re-renders with fresh stock value
END FOR
```

**Pseudocode for Bug 2 Fix Checking:**
```
FOR ALL prescription WHERE isBugCondition2(prescription) DO
  TRY
    eresepProvider.addResep(prescription, obatProvider)
    FAIL "Expected exception but none thrown"
  CATCH ValidationException as e
    ASSERT e.message CONTAINS "Stok tidak mencukupi"
    ASSERT e.details CONTAINS medicine names and available quantities
  END TRY
END FOR
```

### Preservation Checking

**Goal**: Verify that for all inputs where the bug conditions do NOT hold, the fixed functions produce the same result as the original functions.


**Pseudocode for Bug 1 Preservation:**
```
FOR ALL medicineUpdate WHERE NOT (medicineUpdate INCLUDES 'stock_change') DO
  result_original := updateObat_original(medicineUpdate)
  result_fixed := updateObat_fixed(medicineUpdate)
  
  ASSERT result_original == result_fixed
  ASSERT cache updated identically
  ASSERT no additional API calls triggered
END FOR
```

**Pseudocode for Bug 2 Preservation:**
```
FOR ALL prescription WHERE ALL medicines have (quantity <= availableStock) DO
  result_original := addResep_original(prescription)
  result_fixed := addResep_fixed(prescription)
  
  ASSERT result_original == result_fixed
  ASSERT no validation exception thrown
  ASSERT prescription created successfully
END FOR
```

**Testing Approach**: Property-based testing is recommended for preservation checking because:
- It generates many test cases automatically across the input domain
- It catches edge cases that manual unit tests might miss (e.g., boundary values, empty lists, concurrent updates)
- It provides strong guarantees that behavior is unchanged for all non-buggy inputs

**Test Plan**: Observe behavior on UNFIXED code first for non-bug scenarios, then write property-based tests capturing that behavior.


**Preservation Test Cases**:

1. **Non-Stock Medicine Edit Preservation**: 
   - Observe on unfixed code: Edit medicine name/category → Save succeeds → Cache updated
   - Write test: Verify fixed code produces identical behavior for name-only edits

2. **Valid Prescription Creation Preservation**:
   - Observe on unfixed code: Create prescription with quantity ≤ stock → Save succeeds
   - Write test: Verify fixed code accepts valid prescriptions without errors

3. **Manual Refresh Preservation**:
   - Observe on unfixed code: Call fetchObat() → API called → Cache updated
   - Write test: Verify fixed code maintains manual refresh functionality

4. **Search/Filter Preservation**:
   - Observe on unfixed code: Apply filter → Results filtered from cache without API call
   - Write test: Verify fixed code uses same filtering logic without side effects

### Unit Tests

**Bug 1 Fix Tests**:
- Test ObatProvider.updateObat() updates cache and calls notifyListeners()
- Test edit_obat.dart uses provider method instead of direct service call
- Test provider instance shared across screens (integration with Provider scope)
- Test cache consistency after concurrent updates

**Bug 2 Fix Tests**:
- Test EResepProvider.addResep() validates stock before API call
- Test exception thrown when quantity > stock for single medicine
- Test exception message contains medicine name and available quantity
- Test multiple medicines with mixed stock availability
- Test validation uses fresh ObatProvider data

**Preservation Tests**:
- Test non-stock edits (name, category, pricing) work unchanged
- Test valid prescription creation (quantity ≤ stock) works unchanged
- Test error handling for API failures remains unchanged
- Test UI navigation and state management unchanged

### Property-Based Tests

**Bug 1 Properties**:

1. **Stock Update Propagation Property**:
   ```
   PROPERTY: For any medicine M and stock value S,
     WHEN adminProvider.updateObat(M with stock=S) succeeds
     THEN petugasProvider.obatList.find(M).stok == S
     WITHIN next render cycle
   ```

2. **Cache Consistency Property**:
   ```
   PROPERTY: For any ObatProvider instance P1, P2 observing same data,
     WHEN P1.updateObat(medicine) succeeds
     THEN P2.obatList reflects same update after notifyListeners()
   ```

**Bug 2 Properties**:

1. **Stock Validation Enforcement Property**:
   ```
   PROPERTY: For any prescription R with medicine M where M.quantity > M.availableStock,
     addResep(R) MUST throw ValidationException
   ```

2. **Valid Prescription Acceptance Property**:
   ```
   PROPERTY: For any prescription R where ALL medicines have quantity ≤ availableStock,
     addResep(R) MUST complete successfully without exceptions
   ```

**Preservation Properties**:

1. **Non-Stock Edit Equivalence Property**:
   ```
   PROPERTY: For any medicine update U where U does NOT modify stock field,
     updateObat_fixed(U) PRODUCES same result as updateObat_original(U)
   ```

2. **Filter/Search Invariance Property**:
   ```
   PROPERTY: For any search query Q and filter F,
     Applying Q and F on fixed code PRODUCES same filtered results as original code
   ```

### Integration Tests

**End-to-End Bug 1 Test**:
1. Launch app with admin and petugas contexts
2. Admin navigates to edit_obat.dart for medicine "Cefadroxil"
3. Admin changes stock from 80 to 50 and saves
4. Petugas views detail_eresep.dart
5. Verify petugas sees updated stock value 50 (not cached 80)

**End-to-End Bug 2 Test**:
1. Launch app and navigate to detail_eresep.dart
2. Create prescription with "Mylanta" quantity 30
3. Set available stock to 20 in test data
4. Attempt to save prescription
5. Verify error message displayed: "Stok tidak mencukupi: Mylanta - diminta 30, tersedia 20"
6. Verify prescription NOT saved to database

**Cross-Feature Integration Test**:
1. Admin updates multiple medicine stocks
2. Petugas creates prescription with updated stock values
3. Verify prescription validation uses fresh stock data
4. Verify successful save for valid quantities
5. Verify blocked save for insufficient stock

**Concurrent Update Test**:
1. Simulate admin updating stock in background
2. Petugas has prescription form open
3. Petugas attempts to save prescription
4. Verify validation uses latest stock values (fresh fetch before save)
5. Verify no race conditions or stale data issues

**Performance Test**:
1. Create dataset with 100+ medicines
2. Admin updates multiple stocks rapidly
3. Verify all provider instances synchronized within acceptable latency (<500ms)
4. Verify no memory leaks from notifyListeners() calls
5. Verify UI remains responsive during updates
