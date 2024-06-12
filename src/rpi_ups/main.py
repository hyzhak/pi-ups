import pygame, sys

print('start')

pygame.init()
screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
print('screen:', screen)
pygame.display.set_caption("Touch Experiment")


def hsva_color(h, s, v, a):
    c = pygame.Color(0, 0, 0, 0)
    c.hsva = (h, s, v, a)
    return c


colors = [hsva_color(h, 100, 50, 100) for h in range(0, 360, 360 // 32)]

red = (255, 0, 0)
green = (0, 255, 0)
blue = (0, 0, 255)
white = (255, 255, 255)
x, y = 0, 0
fingers = {}
while True:
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()

        if event.type == pygame.FINGERDOWN:
            x = event.x * screen.get_width()
            y = event.y * screen.get_height()
            fingers[event.finger_id] = x, y

        if event.type == pygame.FINGERMOTION:
            x = event.x * screen.get_width()
            y = event.y * screen.get_height()
            fingers[event.finger_id] = x, y

        if event.type == pygame.FINGERUP:
            fingers.pop(event.finger_id, None)

    screen.fill((0, 0, 0))

    for finger_id, (x, y) in fingers.items():
        pygame.draw.circle(screen, colors[finger_id % len(colors)], (x, y), 50)

    pygame.display.update()
