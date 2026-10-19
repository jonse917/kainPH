# Cursor Prompt — Implement KainPH POS UI from the Approved Mockup

You are working in the existing KainPH workspace. Implement a polished Flutter UI sample for **KainPH POS** based on `assets/reference/kainph_pos_uiux_mockup.png` from the supplied asset pack. This is a UI/UX implementation task, not a full POS business-logic implementation.

## Before editing
1. Inspect the existing workspace, Git status, `apps/kainph_pos`, current Flutter dependencies, routes, themes, and folder conventions.
2. Preserve all existing work. Do not reset Git, delete files, replace the database, or modify Supabase migrations.
3. Confirm the asset pack location. If it is outside the repository, copy only the necessary assets into `apps/kainph_pos/assets/` and update `pubspec.yaml` safely. Do not assume paths without checking.
4. Keep POS, FoodBook, and Admin separate. Do not modify FoodBook or Admin for this task.

## Visual direction
Match the reference's warm coffee-brown, cream, and KainPH-orange identity:
- Dark coffee navigation and top bar.
- Cream workspace and cards.
- Orange primary actions and selected navigation.
- Readable typography, restrained rounded corners, subtle borders, and clear spacing.
- Strong visual hierarchy for product prices, cart total, and payment action.
- Consistent icons and product-image aspect ratios.
- Responsive desktop/tablet/mobile behavior. On small screens, do not force the desktop three-column layout; use a compact navigation pattern and a separate cart/order view or sheet.
- Provide accessible contrast, keyboard support on desktop, loading/empty/error states, and visible online/offline/pending-sync status.

## Separate-file architecture
Use feature-first organization and separate files. Reuse existing conventions where appropriate. A suggested structure is:

- `lib/app/app.dart`
- `lib/app/router.dart`
- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/widgets/primary_button.dart`
- `lib/core/widgets/section_card.dart`
- `lib/core/widgets/status_badge.dart`
- `lib/shared/layouts/pos_shell.dart`
- `lib/shared/navigation/pos_navigation.dart`
- `lib/features/auth/presentation/sign_in_screen.dart`
- `lib/features/dashboard/presentation/dashboard_screen.dart`
- `lib/features/sales/presentation/pos_screen.dart`
- `lib/features/sales/presentation/widgets/category_filter.dart`
- `lib/features/sales/presentation/widgets/product_card.dart`
- `lib/features/sales/presentation/widgets/product_grid.dart`
- `lib/features/sales/presentation/widgets/order_panel.dart`
- `lib/features/sales/presentation/widgets/payment_method_tile.dart`
- `lib/features/sales/presentation/widgets/payment_screen.dart`
- `lib/features/sales/presentation/widgets/receipt_preview.dart`
- `lib/features/products/presentation/products_screen.dart`

This is a guide, not a requirement to create unused files. Avoid giant widgets and avoid introducing unnecessary packages.

## Screens to implement for the sample
1. **Sign-in sample** — coffee-themed visual, username/email field, password field, sign-in button, optional PIN entry. Do not pretend authentication works if Supabase auth is not connected.
2. **POS selling screen** — navigation, branch selector, online/offline/pending-sync indicator, category filters, search, product grid, persistent order panel, quantity controls, subtotal, discount entry placeholder, total, and payment method choices.
3. **Payment sample** — amount due, payment method selector, amount received/change for cash, and complete-sale button. Clearly mark any demo-only interactions; do not create a real sale unless connected to the existing service.
4. **Receipt preview** — a preview based on a clearly labeled demo fixture or an existing persisted sale. Printing and sending should not claim success without an actual implementation.
5. **Product management sample** — search, filters, table/list, product status, and add/edit action placeholders.
6. **Dashboard sample** — summary cards, a simple sales chart only if an existing chart dependency is available or a lightweight custom visualization is feasible, and top products using demo data clearly labeled as such.

## Asset usage
- Use the supplied composite mockup as a visual reference only; do not display the entire composite as the app UI.
- The cropped wordmark, background, and product images are reference extracts and may include artifacts. Use them only if they look clean at the intended size.
- Prefer a clean typographic KainPH wordmark or a simple locally implemented icon until a proper logo asset is supplied.
- Never use remote image URLs or CDNs as runtime dependencies. Bundle clean assets locally.
- Do not treat the example prices, branch, cashier, sales totals, or receipt information as actual production data.

## Architecture and safety
- Keep UI separate from domain logic, repositories, and database services.
- Do not rewrite or alter Drift tables, migrations, outbox logic, Supabase schema, authentication policies, or transaction rules in this UI task.
- If the existing local product repository is available, use it through its established interface. Otherwise use a small isolated demo fixture, clearly named as mock data.
- No fake online status, fake synchronization success, fake payment processing, or fake receipt-print success.
- Do not invent tax, senior/PWD discount, or payment-provider rules.

## Validation
1. Format changed Dart files.
2. Run `flutter analyze` and relevant tests.
3. Run `flutter run -d chrome` or a web build if the environment supports it.
4. Test responsive layout and ensure no overflow at desktop, tablet, and mobile widths.
5. Report exact files changed, commands executed, real results, and limitations.

## Definition of done
A coherent, attractive Flutter POS sample exists in separate maintainable files, closely follows the approved mockup, uses the KainPH coffee/cream/orange identity, behaves responsively, and does not damage the existing data or backend foundation. This task is a UI sample only, not a claim that production sales, authentication, printing, or cloud synchronization are complete.
