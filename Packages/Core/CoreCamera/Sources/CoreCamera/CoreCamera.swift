/// Marker for the CoreCamera module. Real types live in their own files.
///
/// The types inside keep their `VIRB*` names: VIRB is Garmin's own protocol, the vocabulary the
/// reverse-engineered `API_ANALYSIS.md` and `openapi.json` are written in, and the wire format the
/// Citroën ConnectedCAM actually speaks. The *module* is named for its role, per the naming rule;
/// the protocol keeps its real name the way `CoreLocation` vends `CLLocationManager`.
enum CoreCamera {}
