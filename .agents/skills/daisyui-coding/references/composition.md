# Component choices in a real interface

Read when composing a page, choosing between visually similar controls, or
fixing a layout that works only with ideal content. The source case is the
[daisyUI documentation application in v5.7.39](https://github.com/saadeghi/daisyui/tree/dd0a94a20ae35c7587017766cef9f0c109ff819b/packages/docs/src).
Its Svelte implementation is evidence of UI decisions, not a framework choice
for the consuming project.

## A navigation drawer has different roles at different widths

In `routes/(routes)/+layout.svelte`, the application computes whether the
current route has sidebar content before applying `lg:drawer-open`. The
`drawer-content` contains the main page; the side region owns navigation and its
scrolling. `components/Sidebar.svelte` renders mobile and desktop menu
presentations from navigation data.

The layout also computes whether main content should be inert: an open
mobile-style drawer can cover it, while a persistent desktop sidebar should
leave the main page usable. It closes an incompatible open state after a
width/context change. These are explicit application behaviors; the drawer's
appearance alone does not supply every focus and navigation guarantee.

For a small site, first decide whether navigation needs an overlay at all. A
short set of ordinary links that wraps on narrow screens may be sufficient. Use
a drawer when content density justifies it, then state which region scrolls,
what closes it, and what happens when resizing across its layout breakpoint. Do
not copy the documentation site's exact width, navigation hierarchy, or
framework state merely because it is an upstream example.

A useful review varies content, not only viewport width: a long page title, long
navigation labels, an empty menu, and a narrow content area. If both the page
and a nested region scroll unintentionally, identify the element that owns
height and overflow before adding more arbitrary height utilities.

## Tabs can be navigation or a local panel selector

At the same revision, `packages/daisyui/src/components/tab.css` displays a
`.tab-content` immediately following an active/selected tab or checked radio.
That adjacent-sibling relationship explains why an extra wrapper can break a
seemingly correct set of classes. The CSS also styles `aria-current="page"` for
navigation. Neither selector provides a complete ARIA tabs interaction.

Choose by the user action:

| Intent                        | Starting choice                          | Contract to retain                                                          |
| ----------------------------- | ---------------------------------------- | --------------------------------------------------------------------------- |
| Navigate to another URL       | Links, optionally styled as tabs         | Real hrefs and current-page indication.                                     |
| Choose one local option/panel | Native radios when suitable              | One group per instance, labels, and the documented panel relationship.      |
| Operate an ARIA tab widget    | Buttons plus a complete tabs interaction | Selected state, focus movement, keyboard behavior, and panel relationships. |

Do not add `role="tab"` to a normal navigation link solely for its appearance.
For two radio groups on one page, use distinct names; otherwise changing the
second instance can deselect the first even when their IDs differ. CSS class
names cannot repair that native grouping mistake.

## Dialog and popover have different behavior

`modal.css` recognizes native dialog `open` and popover-open states as well as
class/checkbox mechanisms. Native modal dialog behavior comes from opening it as
a modal, not from applying `modal-open` to a div. A popover is suitable for
non-modal disclosure; it does not become modal because it uses the same box
styling. See the [modal guide](components/modal.md) for the supported markup.

Choose the interaction before the container's visual treatment. Provide an
accessible name and an actual close action. Decide what opening/closing should
do to focus and verify that the relevant native behavior or application binding
provides it. Disabled styling also needs the control's actual disabled contract.

## Derive visual states from meaningful outcomes

Use semantic surface/content colors consistently within the supported themes.
Keep pending, successful, failed, empty, and disabled states distinct when the
feature has those outcomes. Showing a spinner should not remove the control's
name or unexpectedly move nearby content. Keep important feedback visible
without relying on color or a short-lived toast alone.

For a composition change, exercise ordinary and long content, keyboard focus,
the actual responsive transition, and relevant outcome states. Upstream CSS
inspection explains structure; it is not a claim that an application has passed
visual or accessibility testing. This reference does not prescribe Scheme class
scanning; use [build integration](build-integration.md) when connecting a
template renderer to Tailwind.
