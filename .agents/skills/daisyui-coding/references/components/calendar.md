### Calendar

The calendar component includes styles for different calendar libraries. The
selected library supplies the calendar behavior and must already be available in
the project; daisyUI supplies the styles. Choose the integration that matches
the existing renderer and dependency set.

[Calendar documentation](https://daisyui.com/components/calendar/)

#### Class names

- component
  - `cally (for Cally web component)`
  - `react-day-picker (for the DayPicker component)`
  - `vc (for Vanilla Calendar Pro)`

#### Syntax

Cally:

```html
<calendar-date class="cally">{CONTENT}</calendar-date>
```

React Day Picker:

```html
<DayPicker className="react-day-picker"></DayPicker>
```

Vanilla Calendar Pro:

```html
<div id="calendar" class="vc"></div>
```

```js
import { Calendar } from "vanilla-calendar-pro"

const calendar = new Calendar("#calendar")
calendar.init()
```

#### Rules

- daisyUI supports Cally, React Day Picker, and Vanilla Calendar Pro.
