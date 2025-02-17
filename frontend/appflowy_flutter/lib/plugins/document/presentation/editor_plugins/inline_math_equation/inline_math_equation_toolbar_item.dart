import 'package:appflowy/generated/locale_keys.g.dart';
import 'package:appflowy/plugins/document/presentation/editor_plugins/plugins.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flowy_infra/image.dart';
import 'package:flutter/material.dart';

final ToolbarItem inlineMathEquationItem = ToolbarItem(
  id: 'editor.inline_math_equation',
  group: 2,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState) {
    final selection = editorState.selection!;
    final nodes = editorState.getNodesInSelection(selection);
    final isHighlight = nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes(
        (attributes) => attributes[InlineMathEquationKeys.formula] != null,
      );
    });
    return IconItemWidget(
      iconBuilder: (_) => svgWidget(
        'editor/math',
        size: const Size.square(16),
        color: isHighlight ? Colors.lightBlue : Colors.white,
      ),
      isHighlight: isHighlight,
      tooltip: LocaleKeys.document_plugins_createInlineMathEquation.tr(),
      onPressed: () async {
        final selection = editorState.selection;
        if (selection == null || selection.isCollapsed) {
          return;
        }
        final node = editorState.getNodeAtPath(selection.start.path);
        final delta = node?.delta;
        if (node == null || delta == null) {
          return;
        }

        final transaction = editorState.transaction;
        if (isHighlight) {
          final formula = delta
              .slice(selection.startIndex, selection.endIndex)
              .whereType<TextInsert>()
              .firstOrNull
              ?.attributes?[InlineMathEquationKeys.formula];
          assert(formula != null);
          if (formula == null) {
            return;
          }
          // clear the format
          transaction.replaceText(
            node,
            selection.startIndex,
            selection.length,
            formula,
            attributes: {},
          );
        } else {
          final text = editorState.getTextInSelection(selection).join();
          transaction.replaceText(
            node,
            selection.startIndex,
            selection.length,
            '\$',
            attributes: {
              InlineMathEquationKeys.formula: text,
            },
          );
        }
        await editorState.apply(transaction);
      },
    );
  },
);
