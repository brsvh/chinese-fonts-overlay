### Filter

A filter styles a choice group. The radio variant hides other choices after
selection and exposes a reset action. The inspected v5.7.39 CSS also supports
checkbox choices without collapsing unselected options, although that release's
official skill describes only radios. See [version alignment](../versions.md)
and verify the installed release when adapting this guide.

This component does not implement catalog matching, select-all, or URL state.
For a persistent multi-select grid with a separate select-all control, ordinary
checkboxes or pressed buttons may fit better than the `filter` wrapper. Follow
the product's selection and visibility requirements.

[Filter documentation](https://daisyui.com/components/filter/)

#### Class names

- component: `filter`
- part: `filter-reset`

#### Syntax

HTML form:

```html
<form class="filter">
  <input class="btn btn-square" type="reset" value="×" aria-label="Clear filters"/>
  <input class="btn" type="radio" name="{NAME}" aria-label="Tab 1 title"/>
  <input class="btn" type="radio" name="{NAME}" aria-label="Tab 2 title"/>
</form>
```

No HTML form:

```html
<div class="filter">
  <input class="btn filter-reset" type="radio" name="{NAME}" aria-label="Clear filters"/>
  <input class="btn" type="radio" name="{NAME}" aria-label="Tab 1 title"/>
  <input class="btn" type="radio" name="{NAME}" aria-label="Tab 2 title"/>
</div>
```

#### Rules

- Replace `{NAME}` with a value that identifies the filter.
- Use a different `name` attribute for each set of radio inputs. This prevents
  conflicts.
- Use a form only when its submission and reset semantics fit the surrounding
  page. Do not nest forms. The non-form example uses a radio with
  `filter-reset`; a native reset input has `type="reset"`.
- Set initial selection from the application contract. A native form reset
  restores initial checked states; it does not necessarily clear all choices or
  update the application's URL and result set.

#### Multiple choices

```html
<fieldset>
  <legend>Categories</legend>
  <div class="filter">
    <input class="btn" type="checkbox" name="categories" value="books"
           aria-label="Books" />
    <input class="btn" type="checkbox" name="categories" value="music"
           aria-label="Music" />
  </div>
</fieldset>
```

Use checkboxes for independent choices, not radios with different names.
Selection logic, counts, select-all state, and any reset action remain the
application's responsibility. See [checkbox](checkbox.md) for partial group
selection.
