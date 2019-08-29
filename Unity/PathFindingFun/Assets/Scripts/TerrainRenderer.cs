using UnityEngine;
using System.Collections;

public class TerrainRenderer : MonoBehaviour
{
    public World world;

    float tileSize = 56;
    float altitudeScale = 5;
    
    void Start()
    {
        GenerateTerrainMesh();
    }

    // Update is called once per frame
    void Update()
    {

    }

    void GenerateTerrainMesh()
    {

    }

    Vector3 GetNodePos(MapPoint pt)
    {
        float altitude = world.GetNode(pt).altitude;
        Vector3 result = new Vector3(tileSize * pt.x, altitude * altitudeScale, tileSize * pt.y);
        if ((pt.y & 1) != 0)
        {
            result.x += tileSize / 2;
        }
        return result;
    }


}
