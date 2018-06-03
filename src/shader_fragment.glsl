#version 330 core

// Atributos de fragmentos recebidos como entrada ("in") pelo Fragment Shader.
// Neste exemplo, este atributo foi gerado pelo rasterizador como a
// interpolação da cor de cada vértice, definidas em "shader_vertex.glsl" e
// "main.cpp".
in vec4 position_world;
in vec4 normal;

// Posição do vértice atual no sistema de coordenadas local do modelo.
in vec4 position_model;

// Coordenadas de textura obtidas do arquivo OBJ (se existirem!)
in vec2 texcoords;

// Matrizes computadas no código C++ e enviadas para a GPU
uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

// Identificador que define qual objeto está sendo desenhado no momento
#define SPOTLIGHT 0
#define BUNNY  1
#define PLANE  2
uniform int object_id;


// Parâmetros da axis-aligned bounding box (AABB) do modelo
uniform vec4 bbox_min;
uniform vec4 bbox_max;

// Variáveis para acesso das imagens de textura
uniform sampler2D TextureImage0;
uniform sampler2D TextureImage1;
uniform sampler2D TextureImage2;

uniform vec4 camera_position;
// Atributos uteis a lanterna
uniform vec4 camera_view_vector;
uniform vec4 spotlight_down_offset_vector;
uniform vec4 spotlight_left_offset_vector;

// O valor de saída ("out") de um Fragment Shader é a cor final do fragmento.
out vec3 color;

void main()
{

    // Obtemos a posição da câmera utilizando a inversa da matriz que define o
    // sistema de coordenadas da câmera.
    vec4 origin = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 camera_position = inverse(view) * origin;

    // Spotlight
    vec4 spotlight_position = camera_position 
                            + 0.45*camera_view_vector 
                            + spotlight_down_offset_vector 
                            + spotlight_left_offset_vector;
    vec4 spotlight_orientation = camera_view_vector;
    float spotlight_inner_angle = radians(45.0);
    float spotlight_outer_angle = radians(50.0);


    // O fragmento atual é coberto por um ponto que percente à superfície de um
    // dos objetos virtuais da cena. Este ponto, p, possui uma posição no
    // sistema de coordenadas global (World coordinates). Esta posição é obtida
    // através da interpolação, feita pelo rasterizador, da posição de cada
    // vértice.
    vec4 p = position_world;

    // Normal do fragmento atual, interpolada pelo rasterizador a partir das
    // normais de cada vértice.
    vec4 n = normalize(normal);

    // Vetor que define o sentido da fonte de luz em relação ao ponto atual.
    vec4 l = normalize((spotlight_position - p) - spotlight_orientation);

    // Vetor que define o sentido da câmera em relação ao ponto atual.
    vec4 v = normalize(camera_position - p);

    // Vetor que define o sentido da reflexão especular ideal.
    vec4 r = -l + 2*n*dot(n, l); // PREENCHA AQUI o vetor de reflexão especular ideal

    // Parâmetros que definem as propriedades espectrais da superfície
    vec3 Kd; // Refletância difusa
    vec3 Ks; // Refletância especular
    vec3 Ka; // Refletância ambiente
    float q; // Expoente especular para o modelo de iluminação de Phong
    vec3 Kd0; // Refletância difusa

    // Coordenadas de textura U e V
    float U = 0.0;
    float V = 0.0;

    if ( object_id == SPOTLIGHT )
    {
        U = texcoords.x;
        V = texcoords.y;

        // Propriedades espectrais da lanterna
        Kd = texture(TextureImage2, vec2(U,V)).rgb;
        Ks = vec3(0.0,0.0,0.0);
        Ka = Kd/2;
        q = 1.0;

    }
    else if ( object_id == BUNNY )
    {

        float minx = bbox_min.x;
        float maxx = bbox_max.x;

        float miny = bbox_min.y;
        float maxy = bbox_max.y;

        float minz = bbox_min.z;
        float maxz = bbox_max.z;

        
        U = (position_model.x - minx) / (maxx - minx);
        V = (position_model.y - miny) / (maxy - miny);

        // Propriedades espectrais do coelho
        Kd = texture(TextureImage1, vec2(U,V)).rgb;
        Ks = vec3 (0.8, 0.8, 0.8);
        Ka = Kd/5;
        q = 5.0;
    }
    else if ( object_id == PLANE )
    {
        // Propriedades espectrais do plano
        Kd = vec3(0.2, 0.2, 0.2);
        Ks = vec3(0.3, 0.3, 0.3);
        Ka = vec3(0.01, 0.01, 0.01);
        q = 20.0;
    }
    else // Objeto desconhecido = preto
    {
        Kd = vec3(0.0,0.0,0.0);
        Ks = vec3(0.0,0.0,0.0);
        Ka = vec3(0.0,0.0,0.0);
        q = 1.0;
    }


    // Espectro da fonte de iluminação
    vec3 I = vec3(1.0, 1.0, 1.0); // PREENCHA AQUI o espectro da fonte de luz

    // Espectro da luz ambiente
    vec3 Ia = vec3 (0.1, 0.1, 0.1); // PREENCHA AQUI o espectro da luz ambiente


    // Termo difuso utilizando a lei dos cossenos de Lambert 
    vec3 lambert_diffuse_term = Kd*I*max(0, dot(l, n)); // PREENCHA AQUI o termo difuso de Lambert

    // Termo ambiente
    vec3 ambient_term = Ka*Ia; // PREENCHA AQUI o termo ambiente

    // Termo especular utilizando o modelo de iluminação de Phong
    vec3 phong_specular_term  = Ks*I*pow(max(0, dot(r, v)), q); // PREENCH AQUI o termo especular de Phong



    // Angulo atual do raio de luz da lanterna em relacao a um vetor central
    float theta = dot(normalize(p-spotlight_position), normalize(spotlight_orientation));

    // Computa atenuacao a ser usada
    float distance_to_light = length(spotlight_position - position_world);
    float attenuation_factor = 0.3f;
    float attenuation = 1.0f / (1.0f + (attenuation_factor * pow(distance_to_light, 2)));

    // Computa graduacao da intensidade da lanterna
    float epsilon = spotlight_outer_angle - spotlight_inner_angle;
    float intensity = clamp( (theta - spotlight_outer_angle) / epsilon, 0.0f, 1.0f);



    // Spotlight test
    if(theta > cos(spotlight_outer_angle)){
        color =  attenuation * intensity *(lambert_diffuse_term + phong_specular_term) + ambient_term;
        //color = Kd * max(0, dot(l, n));
    } else {
        color = ambient_term;
    }

    // Cor final com correção gamma, considerando monitor sRGB.
    // Veja https://en.wikipedia.org/w/index.php?title=Gamma_correction&oldid=751281772#Windows.2C_Mac.2C_sRGB_and_TV.2Fvideo_standard_gammas
    color = pow(color, vec3(1.0,1.0,1.0)/2.2);
} 
