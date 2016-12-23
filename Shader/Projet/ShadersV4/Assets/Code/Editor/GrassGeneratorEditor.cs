using UnityEngine;
using UnityEditor;
using System.Collections;

[CanEditMultipleObjects, CustomEditor(typeof(GrassGenerator))]
public class GrassGeneratorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        if (GUILayout.Button("Rebuild grass"))
        {
            ((GrassGenerator)target).Generate();
        }
    }
}
