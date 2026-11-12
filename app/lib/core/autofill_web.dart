import 'dart:js_interop';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:web/web.dart' as web;

/// What a password manager put into a text field's `<input>`.
typedef _Fill = ({web.HTMLElement field, String value, bool typed});

/// The latest fill for each `<input>`, until the next frame hands them over.
final _fills = <_Fill>[];

/// Hands a text field what a password manager wrote into it.
///
/// With semantics on, every text field has an `<input>` on the page, but
/// Flutter listens to it only once the field has focus and a frame has
/// passed. A password manager focuses, blurs and fills the `<input>` within
/// a few milliseconds, or fills it while its own window has the focus, so
/// the value lands while Flutter is not listening and the field stays empty
/// on screen.
void watchAutofill() {
  final listener = _onInput.toJS;
  // Capturing, to read the value before Flutter can write its own over it.
  web.document.addEventListener('input', listener, true.toJS);
  web.document.addEventListener('change', listener, true.toJS);
  web.document.addEventListener('blur', _onBlur.toJS, true.toJS);
}

/// The `<input>` of a text field, if [target] is one.
web.HTMLElement? _textField(web.EventTarget? target) {
  if (target == null || !target.isA<web.HTMLElement>()) return null;
  final field = target as web.HTMLElement;
  return field.getAttribute('data-semantics-role') == 'text-field' ? field : null;
}

/// Keeps Flutter listening when a script takes the focus away from a text
/// field. Password managers do that only to give it straight back, and
/// Flutter, which stops listening on a blur, would not start again: the
/// field would look focused and ignore the keyboard.
void _onBlur(web.FocusEvent event) {
  // Focus moving elsewhere names where it goes, and a window losing focus
  // takes it from the document too.
  if (event.relatedTarget != null || !web.document.hasFocus()) return;
  if (_textField(event.target) != null) event.stopImmediatePropagation();
}

void _onInput(web.Event event) {
  final field = _textField(event.target);
  if (field == null) return;
  final String value;
  if (field.isA<web.HTMLInputElement>()) {
    value = (field as web.HTMLInputElement).value;
  } else if (field.isA<web.HTMLTextAreaElement>()) {
    value = (field as web.HTMLTextAreaElement).value;
  } else {
    return;
  }

  if (_fills.isEmpty) {
    // After a frame Flutter has taken in whatever it did hear, and the
    // layout is ready for finding the field.
    SchedulerBinding.instance.addPostFrameCallback((_) => _deliver());
    SchedulerBinding.instance.ensureVisualUpdate();
  }
  // Only the latest value counts: an earlier one is stale by now.
  _fills.removeWhere((fill) => fill.field == field);
  _fills.add((field: field, value: value, typed: event.isTrusted));
}

void _deliver() {
  final fills = _fills.toList();
  _fills.clear();
  for (final fill in fills) {
    // Its page may have gone meanwhile, and another field be drawn where it
    // was: what was typed for one must never show up in the other.
    if (!fill.field.isConnected) continue;
    final editable = _editableUnder(fill.field);
    if (editable == null || editable.readOnly) continue;
    final state = editable.textSelectionDelegate;
    if (state.textEditingValue.text == fill.value) continue;
    // Typing into a focused field is Flutter's to follow. Where the two
    // differ then, a formatter changed the text.
    if (fill.typed && editable.hasFocus) continue;
    state.userUpdateTextEditingValue(
      TextEditingValue(text: fill.value, selection: TextSelection.collapsed(offset: fill.value.length)),
      SelectionChangedCause.keyboard,
    );
  }
}

/// The text field drawn where [field] is. The `<input>` covers the whole
/// decorated field, so look down its middle for the editable part.
RenderEditable? _editableUnder(web.HTMLElement field) {
  final box = field.getBoundingClientRect();
  final view = field.closest('flutter-view')?.getBoundingClientRect();
  final x = box.left + box.width / 2 - (view?.left ?? 0);
  for (var y = box.top + 2; y < box.bottom; y += 4) {
    final position = Offset(x, y - (view?.top ?? 0));
    for (final renderView in RendererBinding.instance.renderViews) {
      final result = HitTestResult();
      renderView.hitTest(result, position: position);
      for (final entry in result.path) {
        if (entry.target case final RenderEditable editable) return editable;
      }
    }
  }
  return null;
}
