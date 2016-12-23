using UnityEngine;
using UnityEditor;
using System.Collections;

[CanEditMultipleObjects, CustomEditor(typeof(GrassGenerator))] //vient checker ici à chaque fois qu'on fait appel au script GrassGenerator
public class GrassGeneratorEditor : Editor {
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector(); //affiche l'inspector de base
        if (GUILayout.Button("Rebuild grass"))
        {
            ((GrassGenerator)target).Generate(); 
            //target est de classe Object et faut donc la caster 
            //quand on appuie sur le boutton, on appelle Generate()
        }
    }
}
