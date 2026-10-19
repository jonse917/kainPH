# KainPH POS — Starter Design Tokens

These are suggested starting values based on the mockup; refine them in code after reviewing contrast and accessibility.

## Colors
- Coffee 950: `#28170F` — app shell / darkest surfaces
- Coffee 900: `#382116` — sidebar and top navigation
- Coffee 800: `#4A2D1E` — elevated dark surfaces
- KainPH Orange: `#F56B0B` — primary actions and selected states
- Orange Hover: `#DE5900` — hover/pressed state
- Cream 50: `#FFF9F1` — primary light workspace
- Cream 100: `#F7EFE5` — cards and panels
- Sand 200: `#E8DCCE` — borders and separators
- Text Primary: `#241B16`
- Text Secondary: `#75685D`
- Success: `#2E9D57`
- Warning: `#E7A12C`
- Error: `#C53B32`

## Layout guidance
- Desktop POS: collapsible navigation rail/sidebar, product/catalog area, persistent order panel.
- Small screens: switch to compact navigation and a dedicated cart/order route or sheet; do not squeeze the desktop three-column layout onto a phone.
- Use consistent spacing multiples of 4 or 8.
- Suggested card radius: 12–16 logical pixels.
- Suggested control height: 44–48 logical pixels, with larger touch targets where practical.
- Use a consistent icon set and avoid mixing filled and outline styles randomly.
- Product images should use consistent aspect ratios and `BoxFit.cover`.
- Provide visible online/offline/pending-sync status, but do not rely on color alone.

## Typography
Use a clean sans-serif family available across targets. Define text styles centrally for display, headline, title, body, label, and monetary totals. Use tabular figures for totals where supported.

## Notes
Do not hard-code mockup prices, sales, cashier names, branch names, or receipt content as real business rules. Load these from models/repositories or clearly labeled demo fixtures.
