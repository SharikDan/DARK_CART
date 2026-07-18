import pygame
import random
import math
from enum import Enum

# Initialize Pygame
pygame.init()

# Game Constants
SCREEN_WIDTH = 1000
SCREEN_HEIGHT = 800
FPS = 60

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
NEON_GREEN = (0, 255, 65)
NEON_YELLOW = (255, 255, 0)
NEON_RED = (255, 0, 0)
NEON_BLUE = (0, 153, 255)
DARK_GRAY = (51, 51, 51)

class GameState(Enum):
    MENU = 1
    PLAYING = 2
    GAME_OVER = 3

class Player:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.width = 40
        self.height = 50
        self.speed = 0
        self.max_speed = 15
        self.acceleration = 0.3
        self.friction = 0.95
        self.velocity_x = 0
        self.velocity_y = 0
        self.health = 100
        self.boost_power = 0
        self.max_boost = 100
        self.rotation = 0

    def update(self, keys):
        # Controls
        if keys[pygame.K_LEFT]:
            self.velocity_x = -6
        elif keys[pygame.K_RIGHT]:
            self.velocity_x = 6
        else:
            self.velocity_x *= 0.9

        if keys[pygame.K_UP]:
            self.speed = min(self.speed + self.acceleration, self.max_speed)
        elif keys[pygame.K_DOWN]:
            self.speed = max(self.speed - self.acceleration * 1.5, 0)
        else:
            self.speed *= self.friction

        # Boost regeneration
        self.boost_power = min(self.boost_power + 0.5, self.max_boost)

        # Update position
        self.x += self.velocity_x
        self.y -= self.speed

        # Keep in bounds
        self.x = max(20, min(self.x, SCREEN_WIDTH - 20))

    def activate_boost(self):
        if self.boost_power > 20:
            self.speed = min(self.speed + 5, self.max_speed * 1.5)
            self.boost_power -= 20
            return True
        return False

    def draw(self, surface):
        # Car body
        pygame.draw.rect(surface, NEON_GREEN, (self.x - self.width/2, self.y - self.height/2, self.width, self.height))
        
        # Car windows
        pygame.draw.rect(surface, NEON_BLUE, (self.x - self.width/2 + 5, self.y - self.height/2 + 5, self.width - 10, 10))
        
        # Headlights
        pygame.draw.circle(surface, NEON_YELLOW, (int(self.x - self.width/2 + 8), int(self.y - self.height/2 + 2)), 3)
        pygame.draw.circle(surface, NEON_YELLOW, (int(self.x + self.width/2 - 8), int(self.y - self.height/2 + 2)), 3)

    def get_rect(self):
        return pygame.Rect(self.x - self.width/2, self.y - self.height/2, self.width, self.height)

class Obstacle:
    def __init__(self, x, y, obstacle_type="car"):
        self.x = x
        self.y = y
        self.obstacle_type = obstacle_type
        self.width = 35 if obstacle_type == "car" else 50
        self.height = 50 if obstacle_type == "car" else 30
        self.speed = 3 if obstacle_type == "car" else 0

    def update(self, player_speed):
        self.y += 8 + player_speed * 0.5

    def draw(self, surface):
        if self.obstacle_type == "car":
            pygame.draw.rect(surface, NEON_RED, (self.x, self.y, self.width, self.height))
            pygame.draw.rect(surface, NEON_YELLOW, (self.x + 5, self.y + 10, 10, 10))
            pygame.draw.rect(surface, NEON_YELLOW, (self.x + 20, self.y + 10, 10, 10))
        elif self.obstacle_type == "barrier":
            pygame.draw.rect(surface, (255, 153, 0), (self.x, self.y, self.width, self.height))
            pygame.draw.rect(surface, NEON_YELLOW, (self.x, self.y, self.width, self.height), 2)
        elif self.obstacle_type == "oil":
            pygame.draw.circle(surface, (50, 50, 50), (int(self.x + self.width/2), int(self.y + self.height/2)), int(self.width/2))

    def get_rect(self):
        return pygame.Rect(self.x, self.y, self.width, self.height)

class Enemy:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.width = 35
        self.height = 50
        self.speed = 2 + random.random() * 2
        self.target_x = x

    def update(self, player_x, player_speed):
        if self.x < player_x:
            self.x += self.speed
        else:
            self.x -= self.speed
        
        self.y += 4 + player_speed * 0.3
        self.target_x = player_x

    def draw(self, surface):
        pygame.draw.rect(surface, NEON_RED, (self.x, self.y, self.width, self.height))
        pygame.draw.rect(surface, NEON_YELLOW, (self.x + 8, self.y + 10, 6, 6))
        pygame.draw.rect(surface, NEON_YELLOW, (self.x + 21, self.y + 10, 6, 6))
        pygame.draw.circle(surface, (255, 102, 0), (int(self.x + self.width/2), int(self.y + self.height/2)), 15, 2)

    def get_rect(self):
        return pygame.Rect(self.x, self.y, self.width, self.height)

class Checkpoint:
    def __init__(self, x, y):
        self.x = x
        self.y = y
        self.width = 80
        self.height = 60
        self.reached = False

    def draw(self, surface):
        pygame.draw.rect(surface, NEON_GREEN, (self.x - self.width/2, self.y - self.height/2, self.width, self.height), 3)
        font = pygame.font.Font(None, 40)
        text = font.render("S", True, NEON_YELLOW)
        surface.blit(text, (self.x - 10, self.y - 20))

    def get_rect(self):
        return pygame.Rect(self.x - self.width/2, self.y - self.height/2, self.width, self.height)

class Particle:
    def __init__(self, x, y, vx, vy, color):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.color = color
        self.life = 1.0
        self.decay = 0.02

    def update(self):
        self.x += self.vx
        self.y += self.vy
        self.life -= self.decay

    def draw(self, surface):
        if self.life > 0:
            alpha = int(self.life * 255)
            color = tuple(int(c * self.life) for c in self.color)
            pygame.draw.circle(surface, color, (int(self.x), int(self.y)), 3)

class Game:
    def __init__(self):
        self.screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
        pygame.display.set_caption("DARK CART - Night Racing")
        self.clock = pygame.time.Clock()
        self.font_large = pygame.font.Font(None, 64)
        self.font_medium = pygame.font.Font(None, 32)
        self.font_small = pygame.font.Font(None, 24)
        
        self.reset_game()

    def reset_game(self):
        self.state = GameState.MENU
        self.player = Player(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 100)
        self.obstacles = []
        self.enemies = []
        self.particles = []
        self.checkpoints = [Checkpoint(SCREEN_WIDTH / 2, 50)]
        
        self.game_time = 90
        self.game_distance = 0
        self.game_score = 0
        self.time_elapsed = 0
        self.escape_success = False

    def handle_input(self):
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return False
            
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_SPACE:
                    if self.state == GameState.MENU:
                        self.start_game()
                    elif self.state == GameState.PLAYING:
                        if self.player.activate_boost():
                            for _ in range(10):
                                vx = (random.random() - 0.5) * 8
                                vy = random.random() * 3 + 2
                                self.particles.append(Particle(
                                    self.player.x, self.player.y + self.player.height/2,
                                    vx, vy, NEON_YELLOW
                                ))
                    elif self.state == GameState.GAME_OVER:
                        self.reset_game()
                        self.start_game()
        
        return True

    def start_game(self):
        self.state = GameState.PLAYING
        self.game_time = 90
        self.game_distance = 0
        self.game_score = 0
        self.time_elapsed = 0
        self.player.health = 100
        self.player.speed = 0
        self.obstacles = []
        self.enemies = []
        self.particles = []

    def update(self):
        if self.state == GameState.PLAYING:
            keys = pygame.key.get_pressed()
            self.player.update(keys)
            
            self.time_elapsed += 1/FPS
            self.game_time -= 1/FPS
            self.game_distance += self.player.speed
            self.game_score += int(self.player.speed) + len(self.enemies) * 10
            
            # Spawn obstacles
            if random.random() < 0.02:
                types = ['car', 'barrier', 'oil']
                obstacle_type = random.choice(types)
                x = random.random() * (SCREEN_WIDTH - 50) + 25
                self.obstacles.append(Obstacle(x, -60, obstacle_type))
            
            # Spawn enemies
            if random.random() < 0.01 and len(self.enemies) < 5:
                x = random.random() * (SCREEN_WIDTH - 35) + 17
                self.enemies.append(Enemy(x, -50))
            
            # Update obstacles
            for obstacle in self.obstacles[:]:
                obstacle.update(self.player.speed)
                
                if obstacle.get_rect().colliderect(self.player.get_rect()):
                    if obstacle.obstacle_type == 'oil':
                        self.player.speed *= 0.5
                    else:
                        self.player.health -= 10
                        for _ in range(20):
                            vx = (random.random() - 0.5) * 10
                            vy = random.random() * 8 - 4
                            self.particles.append(Particle(
                                self.player.x, self.player.y,
                                vx, vy, (255, 102, 0)
                            ))
                
                if obstacle.y > SCREEN_HEIGHT:
                    self.obstacles.remove(obstacle)
            
            # Update enemies
            for enemy in self.enemies[:]:
                enemy.update(self.player.x, self.player.speed)
                
                if enemy.get_rect().colliderect(self.player.get_rect()):
                    self.player.health -= 15
                    for _ in range(25):
                        vx = (random.random() - 0.5) * 12
                        vy = random.random() * 10 - 5
                        self.particles.append(Particle(
                            self.player.x, self.player.y,
                            vx, vy, NEON_RED
                        ))
                
                if enemy.y > SCREEN_HEIGHT:
                    self.enemies.remove(enemy)
            
            # Check checkpoint
            for checkpoint in self.checkpoints:
                if checkpoint.get_rect().colliderect(self.player.get_rect()):
                    self.end_game(True)
            
            # Update particles
            for particle in self.particles[:]:
                particle.update()
                if particle.life <= 0:
                    self.particles.remove(particle)
            
            # Check game over conditions
            if self.game_time <= 0 or self.player.health <= 0:
                self.end_game(False)

    def end_game(self, success):
        self.state = GameState.GAME_OVER
        self.escape_success = success

    def draw(self):
        self.screen.fill(BLACK)
        
        if self.state == GameState.MENU:
            self.draw_menu()
        elif self.state == GameState.PLAYING:
            self.draw_game()
        elif self.state == GameState.GAME_OVER:
            self.draw_game_over()
        
        pygame.display.flip()

    def draw_menu(self):
        # Title
        title = self.font_large.render("DARK CART", True, NEON_YELLOW)
        self.screen.blit(title, (SCREEN_WIDTH//2 - title.get_width()//2, 80))
        
        subtitle = self.font_medium.render("NIGHT RACING", True, NEON_GREEN)
        self.screen.blit(subtitle, (SCREEN_WIDTH//2 - subtitle.get_width()//2, 160))
        
        # Story
        story_text = [
            "STORY:",
            "The city is in darkness. Corporate hunters chase you through abandoned streets.",
            "Your task: survive the night run and reach the safe house before dawn.",
            "Navigate through obstacles, avoid enemies, and escape the city chaos."
        ]
        
        y = 260
        for line in story_text:
            text = self.font_small.render(line, True, NEON_GREEN)
            self.screen.blit(text, (SCREEN_WIDTH//2 - text.get_width()//2, y))
            y += 30
        
        # Controls
        controls_text = [
            "CONTROLS:",
            "← → Arrow Keys - Steer",
            "↑ ↓ Arrow Keys - Accelerate/Brake",
            "Space - Nitro Boost / Start Game"
        ]
        
        y = 460
        for line in controls_text:
            text = self.font_small.render(line, True, NEON_YELLOW)
            self.screen.blit(text, (SCREEN_WIDTH//2 - text.get_width()//2, y))
            y += 30

    def draw_game(self):
        # Road background
        pygame.draw.rect(self.screen, DARK_GRAY, (0, 0, SCREEN_WIDTH, SCREEN_HEIGHT))
        
        # Road lines
        for i in range(5):
            y = (i * 80 - (self.game_distance * 0.5) % (5 * 80)) % SCREEN_HEIGHT
            pygame.draw.line(self.screen, NEON_YELLOW, (SCREEN_WIDTH//2, y), (SCREEN_WIDTH//2, y + 40), 2)
        
        # Draw game objects
        for obstacle in self.obstacles:
            obstacle.draw(self.screen)
        
        for enemy in self.enemies:
            enemy.draw(self.screen)
        
        for checkpoint in self.checkpoints:
            checkpoint.draw(self.screen)
        
        for particle in self.particles:
            particle.draw(self.screen)
        
        # Draw player
        self.player.draw(self.screen)
        
        # Draw HUD
        self.draw_hud()

    def draw_hud(self):
        # Health bar
        pygame.draw.rect(self.screen, DARK_GRAY, (10, SCREEN_HEIGHT - 40, 200, 30))
        health_width = (self.player.health / 100) * 200
        health_color = NEON_GREEN if self.player.health > 50 else (255, 102, 0)
        pygame.draw.rect(self.screen, health_color, (10, SCREEN_HEIGHT - 40, health_width, 30))
        pygame.draw.rect(self.screen, NEON_GREEN, (10, SCREEN_HEIGHT - 40, 200, 30), 2)
        
        health_text = self.font_small.render(f"HEALTH: {int(self.player.health)}", True, NEON_GREEN)
        self.screen.blit(health_text, (15, SCREEN_HEIGHT - 35))
        
        # Boost bar
        pygame.draw.rect(self.screen, DARK_GRAY, (SCREEN_WIDTH - 210, SCREEN_HEIGHT - 40, 200, 30))
        boost_width = (self.player.boost_power / self.player.max_boost) * 200
        pygame.draw.rect(self.screen, NEON_YELLOW, (SCREEN_WIDTH - 210, SCREEN_HEIGHT - 40, boost_width, 30))
        pygame.draw.rect(self.screen, NEON_YELLOW, (SCREEN_WIDTH - 210, SCREEN_HEIGHT - 40, 200, 30), 2)
        
        boost_text = self.font_small.render(f"BOOST: {int(self.player.boost_power)}", True, NEON_YELLOW)
        self.screen.blit(boost_text, (SCREEN_WIDTH - 205, SCREEN_HEIGHT - 35))
        
        # Stats
        stats_text = [
            f"TIME: {max(0, int(self.game_time))}s",
            f"DISTANCE: {int(self.game_distance)}m",
            f"SPEED: {int(self.player.speed * 10)} km/h",
            f"SCORE: {self.game_score}"
        ]
        
        x = 10
        y = 10
        for stat in stats_text:
            text = self.font_small.render(stat, True, NEON_GREEN)
            self.screen.blit(text, (x, y))
            y += 30

    def draw_game_over(self):
        # Draw game state
        self.draw_game()
        
        # Draw overlay
        overlay = pygame.Surface((SCREEN_WIDTH, SCREEN_HEIGHT))
        overlay.set_alpha(200)
        overlay.fill(BLACK)
        self.screen.blit(overlay, (0, 0))
        
        # Game over text
        if self.escape_success:
            title = self.font_large.render("MISSION COMPLETE!", True, NEON_GREEN)
            message = self.font_medium.render("You've escaped the hunters!", True, NEON_YELLOW)
        else:
            title = self.font_large.render("MISSION FAILED!", True, NEON_RED)
            message = self.font_medium.render("The hunters caught you...", True, (255, 102, 0))
        
        self.screen.blit(title, (SCREEN_WIDTH//2 - title.get_width()//2, 150))
        
        # Stats
        stats = [
            f"Time Survived: {int(max(0, self.time_elapsed))}s",
            f"Distance Covered: {int(self.game_distance)}m",
            f"Final Score: {self.game_score}"
        ]
        
        y = 280
        for stat in stats:
            text = self.font_medium.render(stat, True, NEON_GREEN)
            self.screen.blit(text, (SCREEN_WIDTH//2 - text.get_width()//2, y))
            y += 50
        
        self.screen.blit(message, (SCREEN_WIDTH//2 - message.get_width()//2, y + 30))
        
        # Restart instruction
        restart = self.font_small.render("Press SPACE to play again", True, NEON_YELLOW)
        self.screen.blit(restart, (SCREEN_WIDTH//2 - restart.get_width()//2, SCREEN_HEIGHT - 60))

    def run(self):
        running = True
        while running:
            running = self.handle_input()
            self.update()
            self.draw()
            self.clock.tick(FPS)
        
        pygame.quit()

if __name__ == "__main__":
    game = Game()
    game.run()
