//
// Copyright 2025 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

part of '../../../arcgis_maps_toolkit.dart';

/// Display a [UtilityAssociationResult].
class _UtilityAssociationResultWidget extends StatelessWidget {
  const _UtilityAssociationResultWidget({
    required this.utilityAssociationResult,
  });
  final UtilityAssociationResult utilityAssociationResult;

  @override
  Widget build(BuildContext context) {
    // Get the UtilityAssociation.
    final utilityAssociate = utilityAssociationResult.association;
    // Get the related property string of the UtilityAssociation.
    final subtitle = getAssociationProperty();
    // Check if the associated feature is the origin feature of the PopupView.
    final isOriginFeature = this.isOriginFeature(
      context,
      utilityAssociationResult.associatedFeature,
    );

    return ListTile(
      leading: getAssociationTypeIcon(utilityAssociate.associationType),
      // UtilityAssociationResult Title
      title: Text(
        utilityAssociationResult.title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
      ),
      onTap: () => _navigateToAssociationPopupPage(
        context,
        utilityAssociationResult.associatedFeature,
      ),
      trailing: isOriginFeature
          ? const Icon(Icons.arrow_upward)
          : const Icon(Icons.chevron_right),
    );
  }

  // Get the related association property string of the UtilityAssociation.
  String getAssociationProperty() {
    final association = utilityAssociationResult.association;
    final type = association.associationType;
    final feature = utilityAssociationResult.associatedFeature;
    final gid = feature.attributes['GLOBALID'] as Guid;

    if (type == UtilityAssociationType.containment &&
        association.toElement.globalId == gid) {
      return association.isContainmentVisible ? 'Visible: Yes' : 'Visible: No';
    }

    if (type == UtilityAssociationType.junctionEdgeObjectConnectivityMidspan) {
      return '${(association.fractionAlongEdge * 100).toStringAsFixed(2)}%';
    }

    if (type == UtilityAssociationType.connectivity ||
        type == UtilityAssociationType.junctionEdgeObjectConnectivityFromSide ||
        type == UtilityAssociationType.junctionEdgeObjectConnectivityMidspan ||
        type == UtilityAssociationType.junctionEdgeObjectConnectivityToSide) {
      if (association.fromElement.globalId == gid &&
          association.fromElement.terminal != null) {
        return association.fromElement.terminal!.name;
      }
      if (association.toElement.globalId == gid &&
          association.toElement.terminal != null) {
        return association.toElement.terminal!.name;
      }
    }

    return '';
  }

  // Get the association connection type icon.
  Widget getAssociationTypeIcon(UtilityAssociationType type) {
    const assetsPath = 'packages/arcgis_maps_toolkit/assets/icons';
    switch (type) {
      case UtilityAssociationType.junctionEdgeObjectConnectivityFromSide:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-end-left-24.png'),
          size: 24,
        );
      case UtilityAssociationType.junctionEdgeObjectConnectivityToSide:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-end-right-24.png'),
          size: 24,
        );
      case UtilityAssociationType.junctionEdgeObjectConnectivityMidspan:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-middle-24.png'),
          size: 24,
        );
      case UtilityAssociationType.connectivity:
        return const ImageIcon(
          AssetImage('$assetsPath/connection-to-connection-24.png'),
          size: 24,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Check if the associated feature is the origin feature of the PopupView.
  bool isOriginFeature(BuildContext context, ArcGISFeature feature) {
    final state = context.findAncestorStateOfType<_PopupViewState>();
    final key = _getPopupViewKey(feature);
    return state?._isExistingPopupPage(key) ?? false;
  }
}

/// Add a toPopup function to the [ArcGISFeature].
extension on ArcGISFeature {
  Popup toPopup() {
    var popupDefinition = featureTable?.popupDefinition;
    if (popupDefinition == null &&
        getFeatureSubtype() != null &&
        featureTable is ArcGISFeatureTable) {
      popupDefinition = (featureTable! as ArcGISFeatureTable).subtypeSubtables
          .where((subTable) => subTable.subtype == getFeatureSubtype())
          .firstOrNull
          ?.popupDefinition;
    }

    return Popup(geoElement: this, popupDefinition: popupDefinition);
  }
}

// Display the association PopupView.
void _navigateToAssociationPopupPage(
  BuildContext context,
  ArcGISFeature feature,
) {
  final state = context.findAncestorStateOfType<_PopupViewState>();
  // If the popup for this feature is the one that is the original one
  // on the navigation stack, pop back to it.
  final key = _getPopupViewKey(feature);
  if (state != null) {
    if (state._isExistingPopupPage(key)) {
      state._popupWithKey(key);
    } else {
      // otherwise, show a new PopupView.
      final popup = feature.toPopup();
      state._push(
        MaterialPage(
          //fixme is this onClose correct? we want it to exit. I don't think it's used.
          child: _PopupViewInternal(popup: popup),
          key: ValueKey(key),
        ),
      );
    }
  }
}
